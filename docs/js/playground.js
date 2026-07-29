/* FxDart playground engine.
 *
 * Enhances every `.playground` element (containing a <textarea> with starter
 * code) into a CodeMirror editor with Run/Reset buttons and a console pane.
 *
 * How running works:
 *   1. The single-file build of fxdart (assets/fxdart_single.dart) is
 *      invisibly prepended to the user's code (their
 *      `import 'package:fxdart/fxdart.dart';` line is commented out).
 *      Code with no fxdart import — the "native Dart" panels on the
 *      Dart-vs-FxDart comparison pages — skips the merge entirely.
 *   2. The merged source is turned into a JS module. Three sources, in order
 *      of cost: a build-time artifact under pg/ (for code the reader has not
 *      edited), a cached earlier compile, or the DartPad compile service.
 *   3. The module is executed in a sandboxed iframe (frame.html) that has
 *      already been booted with the DDC runtime; print() output streams back
 *      via postMessage.
 *
 * Why this file owns the network instead of the frame: the two DDC runtime
 * artifacts total 17MB, and every run needs a fresh JS context. Fetching them
 * here means they are downloaded once — into a Cache Storage bucket keyed by
 * the compile service's Dart version — and merely handed to each new frame as
 * source text. Frames are also booted ahead of a click, so the unavoidable
 * per-run cost (parsing 17MB of SDK in a brand-new context) happens while the
 * reader is still reading.
 */
(function () {
  'use strict';

  // Localized UI strings. The page generator (tool/build_docs.dart) emits
  // window.FXDART_I18N per locale; the English defaults below are the fallback
  // so this file keeps working standalone and when a key is untranslated.
  var I18N = window.FXDART_I18N || {};
  function t(key, fallback) { return I18N[key] || fallback; }

  var script = document.currentScript;
  var ROOT = script.src.replace(/js\/playground\.js.*$/, '');
  var API = 'https://stable.api.dartpad.dev/api/v3/';
  var ARTIFACTS = 'https://stable.api.dartpad.dev/artifacts/';

  // build_docs.dart emits this with a ?v=<hash> of the bundle's contents, so
  // the URL changes whenever the library does and the cached copy can never
  // be stale. Falls back to the bare path if the page predates that.
  var LIB_URL = ROOT + (window.FXDART_LIB || 'assets/fxdart_single.dart');

  var idle = window.requestIdleCallback
    ? window.requestIdleCallback.bind(window)
    : function (fn) { return setTimeout(fn, 1); };

  // --- versioning -----------------------------------------------------------

  // Compiled output is only valid against the SDK that produced it, so every
  // cache here is keyed by the compile service's Dart version. Without a
  // version we simply do not persist anything — a mismatched pinned SDK would
  // break the playground until the user cleared site data, which is far worse
  // than re-fetching.
  var versionPromise = null;
  function getVersion() {
    if (!versionPromise) {
      versionPromise = fetch(API + 'version')
        .then(function (r) { return r.ok ? r.json() : {}; })
        .then(function (j) { return j.dartVersion || ''; })
        .catch(function () { return ''; });
    }
    return versionPromise;
  }

  function openCache(kind) {
    return getVersion().then(function (v) {
      if (!v || !window.caches) return null;
      return caches.open('fxdart-' + kind + '-' + v);
    }).catch(function () { return null; });
  }

  // Drop buckets from superseded Dart versions; otherwise a long-lived visitor
  // accumulates a 17MB SDK per upgrade.
  function evictOldCaches() {
    if (!window.caches || !caches.keys) return;
    getVersion().then(function (v) {
      if (!v) return;
      var keep = ['fxdart-rt-' + v, 'fxdart-c-' + v];
      return caches.keys().then(function (names) {
        names.forEach(function (name) {
          if (name.indexOf('fxdart-') === 0 && keep.indexOf(name) === -1) {
            caches.delete(name);
          }
        });
      });
    }).catch(function () {});
  }

  function cachedText(cache, url) {
    function fetchIt() {
      return fetch(url).then(function (r) {
        if (!r.ok) throw new Error(url + ' → ' + r.status);
        if (!cache) return r.text();
        return cache.put(url, r.clone())
          .catch(function () {})
          .then(function () { return r.text(); });
      });
    }
    if (!cache) return fetchIt();
    return cache.match(url).then(function (hit) {
      return hit ? hit.text() : fetchIt();
    });
  }

  // --- DDC runtime ----------------------------------------------------------

  var runtimePromise = null;
  function getRuntime() {
    if (!runtimePromise) {
      runtimePromise = openCache('rt').then(function (cache) {
        return Promise.all([
          cachedText(cache, ARTIFACTS + 'ddc_module_loader.js'),
          cachedText(cache, ARTIFACTS + 'dart_sdk_new.js')
        ]);
      }).then(function (parts) {
        return { loader: parts[0], sdk: parts[1] };
      });
      runtimePromise.catch(function () { runtimePromise = null; });
    }
    return runtimePromise;
  }

  // --- fxdart library bundle ------------------------------------------------

  var libPromise = null;
  function getLib() {
    if (!libPromise) {
      libPromise = fetch(LIB_URL).then(function (r) {
        if (!r.ok) {
          throw new Error(t('pgLoadFailed', 'Could not load the FxDart library') +
            ' (' + r.status + ')');
        }
        return r.text();
      });
      libPromise.catch(function () { libPromise = null; });
    }
    return libPromise;
  }

  // Merge the library with user code. User `dart:` imports are hoisted to the
  // top; the fxdart package import is commented out (the library is inlined).
  // Line positions of user code are preserved via commented placeholders so
  // compile errors can be mapped back.
  //
  // tool/playground_source.dart reimplements this byte-for-byte to precompute
  // artifacts at build time — the two must stay in step or the hashes diverge
  // and every page silently falls back to compiling over the network.
  function buildSource(lib, user) {
    var imports = [];
    var body = [];
    user.split('\n').forEach(function (line) {
      var trimmed = line.trim();
      if (/^import\s+['"]package:fxdart\//.test(trimmed)) {
        body.push('// ' + line);
      } else if (/^import\s+['"]dart:/.test(trimmed)) {
        imports.push(line);
        body.push('// (hoisted) ' + line);
      } else {
        body.push(line);
      }
    });
    var pre = imports.join('\n') + (imports.length ? '\n' : '') + lib +
      '\n// ===== user code below =====\n';
    var offset = pre.split('\n').length - 1;
    return { source: pre + body.join('\n'), offset: offset };
  }

  function needsLib(code) {
    return /^\s*import\s+['"]package:fxdart\//m.test(code);
  }

  function remapErrors(text, offset) {
    return text.replace(/main\.dart:(\d+):(\d+)/g, function (m, line, col) {
      var userLine = parseInt(line, 10) - offset;
      return userLine > 0 ? 'line ' + userLine + ':' + col : 'library:' + line + ':' + col;
    });
  }

  // --- compiling ------------------------------------------------------------

  // 53-bit string hash (cyrb53). Only used to key the compile cache, where a
  // collision would mean running the wrong snippet — at a handful of entries
  // per reader the odds are far below the odds of the cache being evicted.
  function hash(str) {
    var h1 = 0xdeadbeef, h2 = 0x41c6ce57;
    for (var i = 0; i < str.length; i++) {
      var ch = str.charCodeAt(i);
      h1 = Math.imul(h1 ^ ch, 2654435761);
      h2 = Math.imul(h2 ^ ch, 1597334677);
    }
    h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507) ^ Math.imul(h2 ^ (h2 >>> 13), 3266489909);
    h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507) ^ Math.imul(h1 ^ (h1 >>> 13), 3266489909);
    return (4294967296 * (2097151 & h2) + (h1 >>> 0)).toString(36);
  }

  function CompileError(message) {
    this.name = 'CompileError';
    this.message = message;
  }
  CompileError.prototype = Object.create(Error.prototype);

  function compileRemote(source) {
    return fetch(API + 'compileNewDDC', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ source: source })
    }).then(function (resp) {
      return resp.text().then(function (text) {
        if (!resp.ok) {
          var msg;
          try { msg = JSON.parse(text).error || text; } catch (e) { msg = text; }
          throw new CompileError(String(msg));
        }
        return JSON.parse(text).result;
      });
    });
  }

  // Compiled bundles run about a megabyte each, so both caches are bounded.
  // Every edit a reader makes produces another one, and a docs site has no
  // business growing its share of their disk without limit.
  var memLimit = 6;
  var diskLimit = 12;
  var memCompile = {};
  var memOrder = [];

  function remember(key, js) {
    if (!memCompile[key]) memOrder.push(key);
    memCompile[key] = js;
    while (memOrder.length > memLimit) delete memCompile[memOrder.shift()];
    return js;
  }

  // Cache.keys() resolves in insertion order, so the oldest entries are first.
  function trimCache(cache) {
    cache.keys().then(function (keys) {
      for (var i = 0; i < keys.length - diskLimit; i++) cache.delete(keys[i]);
    }).catch(function () {});
  }

  function compile(source) {
    var key = hash(source);
    if (memCompile[key]) return Promise.resolve(memCompile[key]);
    return openCache('c').then(function (cache) {
      var url = ROOT + '__compile/' + key;
      function fresh() {
        return compileRemote(source).then(function (js) {
          if (cache) {
            cache.put(url, new Response(js, {
              headers: { 'Content-Type': 'text/javascript' }
            })).then(function () { trimCache(cache); }).catch(function () {});
          }
          return remember(key, js);
        });
      }
      if (!cache) return fresh();
      return cache.match(url).then(function (hit) {
        if (!hit) return fresh();
        return hit.text().then(function (js) { return remember(key, js); });
      });
    });
  }

  // --- build-time artifacts -------------------------------------------------

  // tool/precompile_playgrounds.dart stores gzipped DDC output under pg/. The
  // files are served as opaque bytes (GitHub Pages sends no Content-Encoding
  // for .gz), so decompress by hand — but sniff the magic number first, in
  // case a server does decode it for us.
  function gunzip(buffer) {
    var bytes = new Uint8Array(buffer);
    if (bytes[0] !== 0x1f || bytes[1] !== 0x8b) {
      return Promise.resolve(new TextDecoder().decode(bytes));
    }
    if (typeof DecompressionStream === 'undefined') {
      return Promise.reject(new Error('gzip unsupported'));
    }
    var stream = new Blob([bytes]).stream()
      .pipeThrough(new DecompressionStream('gzip'));
    return new Response(stream).text();
  }

  function fetchPrebuilt(id) {
    return fetch(ROOT + 'pg/' + id + '.js.gz').then(function (r) {
      if (!r.ok) throw new Error('no prebuilt artifact');
      return r.arrayBuffer();
    }).then(gunzip);
  }

  // --- execution frames -----------------------------------------------------

  var frames = [];

  window.addEventListener('message', function (e) {
    for (var i = 0; i < frames.length; i++) {
      if (frames[i].el.contentWindow === e.source) {
        frames[i].handle(e.data || {});
        return;
      }
    }
  });

  function Frame() {
    var self = this;
    this.onOutput = null;

    this._ready = new Promise(function (res) { self._readyRes = res; });
    this._warm = new Promise(function (res, rej) {
      self._warmRes = res;
      self._warmRej = rej;
    });

    this.el = document.createElement('iframe');
    this.el.setAttribute('sandbox', 'allow-scripts');
    this.el.setAttribute('aria-hidden', 'true');
    this.el.setAttribute('title', 'FxDart playground runtime');
    this.el.style.display = 'none';
    frames.push(this);
    this.el.src = ROOT + 'frame.html';
    document.body.appendChild(this.el);

    Promise.all([this._ready, getRuntime()]).then(function (r) {
      if (!self.el.contentWindow) return;
      self.el.contentWindow.postMessage(
        { command: 'boot', loader: r[1].loader, sdk: r[1].sdk }, '*');
    }).catch(function (err) { self._warmRej(err); });
  }

  Frame.prototype.handle = function (d) {
    if (d.sender !== 'fx-frame') return;
    if (d.type === 'ready') return this._readyRes();
    if (d.type === 'warm') return this._warmRes(this);
    if (d.type === 'bootfail') return this._warmRej(new Error(d.message));
    if (this.onOutput) this.onOutput(d);
  };

  Frame.prototype.warm = function () { return this._warm; };

  Frame.prototype.execute = function (js) {
    this.el.contentWindow.postMessage({ command: 'execute', js: js }, '*');
  };

  Frame.prototype.destroy = function () {
    var i = frames.indexOf(this);
    if (i >= 0) frames.splice(i, 1);
    this.onOutput = null;
    this.el.remove();
  };

  // At most two frames are alive: the one that last ran (kept around so late
  // async print() output still lands somewhere) and a pre-booted spare. A run
  // anywhere on the page reclaims the previous one, so a page full of
  // playgrounds never accumulates SDK-sized contexts.
  var activeFrame = null;
  var spareFrame = null;

  function prewarm() {
    if (spareFrame) return;
    var f = new Frame();
    spareFrame = f;
    f.warm().catch(function () {
      if (spareFrame === f) { spareFrame = null; f.destroy(); }
    });
  }

  function acquireFrame() {
    if (activeFrame) { activeFrame.destroy(); activeFrame = null; }
    var f = spareFrame;
    spareFrame = null;
    if (!f) f = new Frame();
    activeFrame = f;
    return f;
  }

  function releaseFrame(f) {
    if (activeFrame === f) { activeFrame.destroy(); activeFrame = null; }
  }

  // --- UI -------------------------------------------------------------------

  function el(tag, cls, text) {
    var node = document.createElement(tag);
    if (cls) node.className = cls;
    if (text) node.textContent = text;
    return node;
  }

  function enhance(container) {
    var textarea = container.querySelector('textarea');
    if (!textarea) return;
    var initial = textarea.value.replace(/^\n+/, '').replace(/\s+$/, '');
    textarea.value = initial;

    // Set by build_docs.dart when a build-time artifact exists for exactly
    // this snippet. Only valid while the reader has not edited the code.
    var prebuiltId = container.getAttribute('data-pg');

    var toolbar = el('div', 'pg-toolbar');
    var runBtn = el('button', 'pg-run', t('pgRun', '▶ Run'));
    var resetBtn = el('button', 'pg-reset', t('pgReset', 'Reset'));
    var status = el('span', 'pg-status', '');
    toolbar.appendChild(runBtn);
    toolbar.appendChild(resetBtn);
    toolbar.appendChild(status);

    var output = el('pre', 'pg-output');
    output.setAttribute('aria-live', 'polite');
    output.style.display = 'none';

    container.insertBefore(toolbar, textarea);
    container.appendChild(output);

    var editor = null;
    if (window.CodeMirror) {
      editor = CodeMirror.fromTextArea(textarea, {
        mode: 'dart',
        lineNumbers: true,
        indentUnit: 2,
        tabSize: 2,
        viewportMargin: Infinity,
        theme: 'fxdart'
      });
    }
    function getCode() { return editor ? editor.getValue() : textarea.value; }

    var frame = null;
    // Bumped on every Run so a previous run's deferred callbacks can tell
    // they have been superseded — otherwise the "(no output)" timer from an
    // abandoned run fires into the console of the run that replaced it.
    var runSeq = 0;

    function appendOut(text, cls) {
      output.style.display = 'block';
      var line = el('span', cls || '');
      line.textContent = text + '\n';
      output.appendChild(line);
      output.scrollTop = output.scrollHeight;
    }

    // Resolves to {js, offset}. Cheapest source first.
    function resolveJs(code) {
      if (prebuiltId && code.trim() === initial.trim()) {
        return fetchPrebuilt(prebuiltId)
          .then(function (js) { return { js: js, offset: 0 }; })
          .catch(function () { return viaCompiler(code); });
      }
      return viaCompiler(code);
    }

    function viaCompiler(code) {
      // The "native Dart" panels on comparison pages never import fxdart —
      // they compile as-is, with no library merge and no line offset.
      var built = needsLib(code)
        ? getLib().then(function (lib) { return buildSource(lib, code); })
        : Promise.resolve({ source: code, offset: 0 });
      return built.then(function (b) {
        return compile(b.source).then(function (js) {
          return { js: js, offset: b.offset };
        }, function (err) {
          err.offset = b.offset;
          throw err;
        });
      });
    }

    function finish() {
      status.textContent = '';
      runBtn.disabled = false;
      idle(prewarm);
    }

    function run() {
      if (frame) { releaseFrame(frame); frame = null; }
      var seq = ++runSeq;
      output.style.display = 'block';
      output.textContent = '';
      runBtn.disabled = true;
      status.textContent = t('pgCompiling', 'Compiling…');

      // Claim a frame now so its (usually already finished) boot overlaps
      // with resolving the JS instead of following it.
      var f = acquireFrame();
      frame = f;

      var gotOutput = false;
      f.onOutput = function (d) {
        if (d.type === 'started') {
          status.textContent = t('pgRunning', 'Running…');
        } else if (d.type === 'stdout') {
          gotOutput = true;
          appendOut(d.message, 'pg-out');
        } else if (d.type === 'stderr') {
          gotOutput = true;
          appendOut(d.message, 'pg-err');
          finish();
        } else if (d.type === 'done') {
          // main() returned; async work may still print afterwards.
          finish();
          setTimeout(function () {
            if (!gotOutput && seq === runSeq) {
              appendOut(t('pgNoOutput', '(no output)'), 'pg-dim');
            }
          }, 3000);
        }
      };

      resolveJs(getCode()).then(function (res) {
        status.textContent = t('pgLoading', 'Loading runtime…');
        return f.warm().then(function () {
          if (frame !== f) return; // superseded by a newer run
          f.execute(res.js);
        });
      }).catch(function (err) {
        if (err && err.name === 'CompileError') {
          status.textContent = t('pgCompileError', 'Compile error');
          appendOut(remapErrors(String(err.message), err.offset || 0), 'pg-err');
        } else {
          status.textContent = t('pgError', 'Error');
          appendOut(String(err && err.message ? err.message : err), 'pg-err');
        }
        runBtn.disabled = false;
        releaseFrame(f);
        if (frame === f) frame = null;
      });

      // Safety: re-enable Run if nothing came back.
      setTimeout(function () {
        if (seq === runSeq && runBtn.disabled) {
          runBtn.disabled = false;
          status.textContent = '';
        }
      }, 60000);
    }

    runBtn.addEventListener('click', run);
    resetBtn.addEventListener('click', function () {
      runSeq++; // abandon anything still in flight
      if (editor) editor.setValue(initial); else textarea.value = initial;
      output.textContent = '';
      output.style.display = 'none';
      status.textContent = '';
      if (frame) { releaseFrame(frame); frame = null; }
    });
  }

  // --- boot -----------------------------------------------------------------

  // Booting a frame downloads the 17MB runtime, so do not spend a drive-by
  // reader's bandwidth on it. Wait until a playground is actually on screen
  // (or the reader reaches for one), then warm up while they read.
  function armPrewarm(containers) {
    var armed = false;
    function fire() {
      if (armed) return;
      armed = true;
      idle(prewarm);
    }
    containers.forEach(function (c) {
      c.addEventListener('pointerenter', fire, { once: true });
      c.addEventListener('focusin', fire, { once: true });
    });
    if (!window.IntersectionObserver) return;
    var io = new IntersectionObserver(function (entries) {
      for (var i = 0; i < entries.length; i++) {
        if (entries[i].isIntersecting) { io.disconnect(); fire(); return; }
      }
    }, { rootMargin: '200px' });
    containers.forEach(function (c) { io.observe(c); });
  }

  function init() {
    var containers = [].slice.call(document.querySelectorAll('.playground'));
    if (!containers.length) return;
    containers.forEach(enhance);
    evictOldCaches();
    armPrewarm(containers);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
