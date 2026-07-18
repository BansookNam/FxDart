/* FxDart playground engine.
 *
 * Enhances every `.playground` element (containing a <textarea> with starter
 * code) into a CodeMirror editor with Run/Reset buttons and a console pane.
 *
 * How running works:
 *   1. The single-file build of fxdart (assets/fxdart_single.dart) is
 *      invisibly prepended to the user's code (their
 *      `import 'package:fxdart/fxdart.dart';` line is commented out).
 *   2. The merged source is sent to the DartPad compile service (compileDDC).
 *   3. The returned JS module is executed in a fresh sandboxed iframe
 *      (frame.html) with the matching dart_sdk.js; print() output streams
 *      back via postMessage.
 */
(function () {
  'use strict';

  var script = document.currentScript;
  var ROOT = script.src.replace(/js\/playground\.js.*$/, '');
  var COMPILE_URL = 'https://stable.api.dartpad.dev/api/v3/compileNewDDC';

  var libPromise = null;
  function getLib() {
    if (!libPromise) {
      libPromise = fetch(ROOT + 'assets/fxdart_single.dart').then(function (r) {
        if (!r.ok) throw new Error('Could not load fxdart library (' + r.status + ')');
        return r.text();
      });
    }
    return libPromise;
  }

  // Merge the library with user code. User `dart:` imports are hoisted to the
  // top; the fxdart package import is commented out (the library is inlined).
  // Line positions of user code are preserved via commented placeholders so
  // compile errors can be mapped back.
  function buildSource(lib, user) {
    var imports = [];
    var body = [];
    user.split('\n').forEach(function (line) {
      var t = line.trim();
      if (/^import\s+['"]package:fxdart\//.test(t)) {
        body.push('// ' + line);
      } else if (/^import\s+['"]dart:/.test(t)) {
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

  function remapErrors(text, offset) {
    return text.replace(/main\.dart:(\d+):(\d+)/g, function (m, line, col) {
      var userLine = parseInt(line, 10) - offset;
      return userLine > 0 ? 'line ' + userLine + ':' + col : 'library:' + line + ':' + col;
    });
  }

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

    var toolbar = el('div', 'pg-toolbar');
    var runBtn = el('button', 'pg-run', '▶ Run');
    var resetBtn = el('button', 'pg-reset', 'Reset');
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

    var iframe = null;
    var msgHandler = null;

    function cleanup() {
      if (msgHandler) { window.removeEventListener('message', msgHandler); msgHandler = null; }
      if (iframe) { iframe.remove(); iframe = null; }
    }

    function appendOut(text, cls) {
      output.style.display = 'block';
      var line = el('span', cls || '');
      line.textContent = text + '\n';
      output.appendChild(line);
      output.scrollTop = output.scrollHeight;
    }

    function run() {
      cleanup();
      output.style.display = 'block';
      output.textContent = '';
      runBtn.disabled = true;
      status.textContent = 'Compiling…';

      getLib().then(function (lib) {
        var built = buildSource(lib, getCode());
        return fetch(COMPILE_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ source: built.source })
        }).then(function (resp) {
          return resp.text().then(function (text) {
            if (!resp.ok) {
              var msg;
              try { msg = JSON.parse(text).error || text; } catch (e) { msg = text; }
              status.textContent = 'Compile error';
              appendOut(remapErrors(String(msg), built.offset), 'pg-err');
              runBtn.disabled = false;
              return;
            }
            var js = JSON.parse(text).result;
            execute(js);
          });
        });
      }).catch(function (err) {
        status.textContent = 'Error';
        appendOut(String(err), 'pg-err');
        runBtn.disabled = false;
      });
    }

    function execute(js) {
      status.textContent = 'Loading runtime…';
      iframe = document.createElement('iframe');
      iframe.setAttribute('sandbox', 'allow-scripts');
      iframe.style.display = 'none';
      iframe.src = ROOT + 'frame.html';

      var gotOutput = false;
      msgHandler = function (e) {
        if (!iframe || e.source !== iframe.contentWindow) return;
        var d = e.data || {};
        if (d.sender !== 'fx-frame') return;
        if (d.type === 'ready') {
          iframe.contentWindow.postMessage({ command: 'execute', js: js }, '*');
        } else if (d.type === 'started') {
          status.textContent = 'Running…';
        } else if (d.type === 'stdout') {
          gotOutput = true;
          appendOut(d.message, 'pg-out');
        } else if (d.type === 'stderr') {
          gotOutput = true;
          appendOut(d.message, 'pg-err');
          status.textContent = '';
          runBtn.disabled = false;
        } else if (d.type === 'done') {
          // main() returned; async work may still print afterwards.
          status.textContent = '';
          runBtn.disabled = false;
          setTimeout(function () {
            if (!gotOutput) appendOut('(no output)', 'pg-dim');
          }, 3000);
        }
      };
      window.addEventListener('message', msgHandler);
      document.body.appendChild(iframe);

      // Safety: re-enable Run if nothing came back.
      setTimeout(function () {
        if (runBtn.disabled) { runBtn.disabled = false; status.textContent = ''; }
      }, 60000);
    }

    runBtn.addEventListener('click', run);
    resetBtn.addEventListener('click', function () {
      if (editor) editor.setValue(initial); else textarea.value = initial;
      output.textContent = '';
      output.style.display = 'none';
      status.textContent = '';
      cleanup();
    });
  }

  function init() {
    document.querySelectorAll('.playground').forEach(enhance);
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
