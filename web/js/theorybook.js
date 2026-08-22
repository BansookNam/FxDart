/* FxDart Theory — paged book viewer.
 *
 * The page under docs/theory/ ships a flat list of content blocks in a hidden
 * #source element. This file measures those blocks and flows them into
 * fixed-size pages, then renders one spread at a time.
 *
 * Why pagination happens here and not at build time: page capacity depends on
 * the reader's viewport and font settings, and a book whose text is clipped or
 * whose figures straddle a fold is not a book. The build stays layout-free.
 *
 * Spread model — spread 0 is the closed book; spread s shows pages[2s-3] on
 * the left and pages[2s-2] on the right, so even page indices are always
 * right-hand pages. Chapter openers and exercises are forced onto even
 * indices; solutions are forced onto the next page, which is therefore odd and
 * only visible after a turn.
 *
 * Only those two pages exist in the DOM. An earlier version stacked every
 * sheet in 3D and flipped them; with 300 pages the compositor bled stale
 * layers through the current spread (a page numbered 6 showing under the
 * indicator's "8–9"), and no amount of z-index bookkeeping fixed it reliably.
 * Correct beats cute for a reference text.
 *
 * Below ~880px there is no spread: a phone cannot show two 560px pages
 * without scaling them to a quarter, so the viewer flows one page at a time
 * into a box measured from the screen, and moves the controls into a bar
 * under the paper (back · page picker · language · forward). Everything
 * downstream of the page box — the flow, the contents, the anchors — is the
 * same code; only `single` changes. Because the box is measured, a rotation or a resize
 * re-runs the flow and restores the reader by anchor, never by page number.
 */
(function () {
  'use strict';

  var stage = document.getElementById('book-stage');
  var source = document.getElementById('source');
  if (!stage || !source) return;

  var T = window.FXDART_THEORY || {};
  function t(key, fallback) { return T[key] || fallback; }

  // --- page geometry --------------------------------------------------------
  //
  // Two 560px pages side by side cannot be shown on a phone: fitted to a 390px
  // screen the spread lands at 0.28 scale, which is a photograph of a book
  // rather than something anyone can read. Below the threshold the viewer
  // drops the fold and gives one page the whole screen, sized from the
  // viewport instead of from the stylesheet's fixed paper.
  var SINGLE_MAX_W = 880;   // narrower than this and a spread cannot breathe
  var SINGLE_MAX_H = 520;   // a phone held sideways: two pages would be stamps

  var hudEl = document.getElementById('book-hud');
  var scaler = document.getElementById('scaler');
  var stageStyle = getComputedStyle(stage);
  var BOOK_W = parseInt(stageStyle.getPropertyValue('--page-w'), 10) || 520;
  var BOOK_H = parseInt(stageStyle.getPropertyValue('--page-h'), 10) || 690;

  var single = false;
  var PW = BOOK_W, PH = BOOK_H;

  function measureGeometry() {
    single = innerWidth < SINGLE_MAX_W || innerHeight < SINGLE_MAX_H;
    document.body.classList.toggle('book-single', single);
    if (!single) {
      stage.style.removeProperty('--page-w');
      stage.style.removeProperty('--page-h');
      PW = BOOK_W;
      PH = BOOK_H;
      return;
    }
    // One page, as large as the screen allows. What the close strip above the
    // paper and the bar below it take is *measured*, not assumed — the bar's
    // height moves with the reader's font size, and a constant subtracted from
    // the viewport is wrong exactly where it matters.
    //
    // Measured off the stage, never off #scaler: #book is as wide as --page-w,
    // so a box that sizes to its contents would feed the last answer back into
    // the next one and the page would only ever grow.
    var margin = 8;
    var top = parseFloat(getComputedStyle(stage).paddingTop) || 0;
    // The floors are a backstop against a nonsense box, not a target: set
    // above what a phone held sideways leaves over and the paper is taller
    // than the stage, so the page gets clipped at both ends.
    PW = Math.max(240, Math.min(stage.clientWidth - margin * 2, 620));
    PH = Math.max(200, stage.clientHeight - top - hudEl.offsetHeight -
      margin * 2);
    stage.style.setProperty('--page-w', PW + 'px');
    stage.style.setProperty('--page-h', PH + 'px');
  }

  // --- flow: blocks → pages -------------------------------------------------

  // The manuscript stays in #source and is only ever cloned, so the flow can
  // be run again from the top when the page box changes — a rotation gives a
  // different box, and every page break has to be found again for it.
  var srcBlocks = [].slice.call(source.children);
  var blocks = srcBlocks;
  var pages = [];   // {html, kind, chapter, title, part}

  // Offscreen page used to measure. Same box as a real .page-content, so what
  // fits here fits there.
  var meas = document.createElement('div');
  meas.className = 'page';
  // Sized per flow by buildPages(), which is the only thing that knows the
  // current page box.
  meas.style.cssText = 'position:absolute;left:-9999px;top:0;visibility:hidden;';
  var measC = document.createElement('div');
  measC.className = 'page-content';
  meas.appendChild(measC);
  document.body.appendChild(meas);

  var current = [];             // nodes on the page being filled
  var chapter = 0, chapterTitle = '', part = '';

  // scrollHeight ignores the last child's bottom margin, which is enough to
  // let a page measure as fitting and then render one line past the paper.
  // Measure the last child's margin box against the page box instead.
  function contentHeight() {
    var last = measC.lastElementChild;
    if (!last) return 0;
    var gap = last.getBoundingClientRect().bottom -
      measC.getBoundingClientRect().top;
    return gap + (parseFloat(getComputedStyle(last).marginBottom) || 0);
  }

  function fits() { return contentHeight() <= measC.clientHeight + 1; }

  // Run buttons ship without a label so the string stays localizable at
  // runtime — but an empty button is ~24px shorter than a labelled one, and
  // measuring before labelling puts a line of code past the bottom of the
  // page. Label first; everything measured afterwards is what renders.
  [].forEach.call(source.querySelectorAll('.run-btn'), function (b) {
    b.textContent = t('run', '▶ Run');
  });
  [].forEach.call(source.querySelectorAll('.edit-btn'), function (b) {
    b.textContent = t('edit', '✎ Edit');
  });
  [].forEach.call(source.querySelectorAll('.run-out-title'), function (n) {
    n.textContent = t('output', 'Output');
  });
  [].forEach.call(source.querySelectorAll('.run-close'), function (n) {
    n.textContent = '✕';
    n.setAttribute('aria-label', t('close', 'Close'));
  });

  // --- oversized blocks -----------------------------------------------------
  //
  // A long listing or a long table can be taller than a whole page. Left
  // alone it would be clipped at the page edge — text simply missing, with
  // nothing on screen to say so. Such blocks are cut into page-sized parts
  // before the flow starts.

  // Measures a clone, never the node itself: the blocks belong to #source and
  // a reflow needs them intact.
  function fitsAlone(node) {
    measC.innerHTML = '';
    measC.appendChild(node.cloneNode(true));
    var ok = measC.scrollHeight <= measC.clientHeight + 1;
    measC.innerHTML = '';
    return ok;
  }

  // Greedy fill: keep adding rows/lines to `part` until one does not fit,
  // then hand the part back and start the next one. `refill(part)` returns
  // the container the items go into.
  function chunk(block, items, refill, decorate) {
    var parts = [], i = 0, guard = 0;
    while (i < items.length && guard++ < 500) {
      var part = block.cloneNode(true);
      var into = refill(part);
      var used = 0;
      while (i + used < items.length) {
        into.appendChild(items[i + used].cloneNode(true));
        if (!fitsAlone(part)) {
          // One item alone taller than a page: keep it and move on, so the
          // loop always makes progress.
          if (used === 0) used = 1;
          else into.removeChild(into.lastChild);
          break;
        }
        used++;
      }
      i += used;
      parts.push(part);
    }
    if (parts.length < 2) return null;
    parts.forEach(function (p, k) {
      decorate(p, k, parts.length);
    });
    return parts;
  }

  function splitCode(block) {
    var pre = block.classList.contains('code')
      ? block : block.querySelector('pre.code');
    if (!pre) return null;
    var code = pre.querySelector('code');
    var lines = code ? [].slice.call(code.querySelectorAll('.cl')) : [];
    if (lines.length < 4) return null;
    // The Run button compiles the whole program, not the visible slice.
    var src = lines.map(function (n) { return n.textContent; }).join('\n');

    return chunk(block, lines, function (part) {
      // Both continuation markers are present while measuring and removed
      // afterwards where they do not apply: they occupy a line each, and a
      // marker added after the fit check would push the last line off the page.
      part.setAttribute('data-code-from', '1');
      part.setAttribute('data-code-more', '1');
      var p = part.classList.contains('code')
        ? part : part.querySelector('pre.code');
      var c = p.querySelector('code');
      c.innerHTML = '';
      return c;
    }, function (p, k, total) {
      p.setAttribute('data-src', src);
      if (k === 0) p.removeAttribute('data-code-from');
      if (k === total - 1) {
        p.removeAttribute('data-code-more');
      } else {
        // Only the final part carries the Run UI — one button per listing.
        var bar = p.querySelector('.runbar');
        var out = p.querySelector('.run-out');
        if (bar) bar.parentNode.removeChild(bar);
        if (out) out.parentNode.removeChild(out);
      }
    });
  }

  function splitTable(block) {
    if (block.tagName !== 'TABLE') return null;
    var rows = [].slice.call(block.querySelectorAll('tbody tr'));
    if (rows.length < 4) return null;
    // Each part repeats the header, so a split table still reads as a table.
    // The continuation marker goes on before measuring: it can wrap a header
    // cell onto a second line, which is height the fit check has to see.
    return chunk(block, rows, function (part) {
      part.setAttribute('data-table-from', '1');
      var body = part.querySelector('tbody');
      body.innerHTML = '';
      return body;
    }, function (p, k) {
      if (k === 0) p.removeAttribute('data-table-from');
    });
  }

  // Long exercise and solution lists overflow the same way listings do.
  function splitList(block) {
    if (block.tagName !== 'OL' && block.tagName !== 'UL') return null;
    var items = [].slice.call(block.children).filter(function (n) {
      return n.tagName === 'LI';
    });
    if (items.length < 2) return null;
    var parts = chunk(block, items, function (part) {
      part.innerHTML = '';
      return part;
    }, function () {});
    // Numbering continues across the break; `start` costs no height, so it is
    // safe to set after the fit checks.
    if (parts && block.tagName === 'OL') {
      var n = 1;
      parts.forEach(function (p) {
        p.setAttribute('start', String(n));
        n += p.children.length;
      });
    }
    return parts;
  }

  // Depth boxes are blockquotes and can run long; split them by paragraph.
  function splitQuote(block) {
    if (block.tagName !== 'BLOCKQUOTE') return null;
    var kids = [].slice.call(block.children);
    if (kids.length < 2) return null;
    return chunk(block, kids, function (part) {
      part.innerHTML = '';
      return part;
    }, function () {});
  }

  // Flowing the manuscript is a function, not a one-off: the page box can
  // change under the reader (a phone rotates, a window is resized, the viewer
  // crosses into single-page mode) and every break has to be found again for
  // the new box.
  function buildPages() {
    meas.style.width = PW + 'px';
    meas.style.height = PH + 'px';
    measC.innerHTML = '';
    pages.length = 0;
    current = [];
    chapter = 0;
    chapterTitle = '';
    part = '';
    blocks = srcBlocks;

    blocks = blocks.reduce(function (acc, block) {
      if (fitsAlone(block)) return acc.concat([block]);
      var parts = splitCode(block) || splitTable(block) ||
        splitList(block) || splitQuote(block);
      return acc.concat(parts || [block]);
    }, []);

    function closePage(kind) {
      if (!current.length && kind !== 'blank') return;
      pages.push({
        html: current.map(function (n) { return n.outerHTML; }).join(''),
        kind: kind || 'text',
        chapter: chapter,
        title: chapterTitle,
        part: part
      });
      current = [];
      measC.innerHTML = '';
    }

    function padToRecto() {
      // Pages are 0-indexed and even indices are right-hand pages. With one
      // page on screen there is no facing page to protect, so no paper is
      // spent on a blank.
      if (single) return;
      if (pages.length % 2 !== 0) closePage('blank');
    }

    for (var i = 0; i < blocks.length; i++) {
      var block = blocks[i];

      if (block.classList.contains('title-page')) {
        closePage();
        pages.push({ html: block.outerHTML, kind: 'title', chapter: 0, title: '', part: '' });
        continue;
      }

      var opener = block.classList.contains('ch-open');
      if (opener) {
        closePage();
        padToRecto();
        var numEl = block.querySelector('.ch-num');
        var titleEl = block.querySelector('.ch-title');
        var partEl = block.querySelector('.part-tag');
        chapter = numEl ? parseInt(numEl.textContent, 10) || 0 : 0;
        chapterTitle = titleEl ? titleEl.textContent : '';
        part = partEl ? partEl.textContent : '';
      } else if (block.hasAttribute('data-exercise')) {
        closePage();
        padToRecto();
      } else if (block.hasAttribute('data-answers')) {
        closePage();
      }

      var clone = block.cloneNode(true);
      measC.appendChild(clone);
      current.push(clone);

      if (!fits() && current.length > 1) {
        // Doesn't fit: move it (plus any heading that would be orphaned above
        // it) onto a fresh page.
        var carry = [clone];
        measC.removeChild(clone);
        current.pop();
        while (current.length) {
          var last = current[current.length - 1];
          // Pull back anything that would be stranded: a heading with no body
          // under it, and a figure whose caption has just moved on without it.
          var heading = /^H[23]$/.test(last.tagName);
          var caption = last.classList.contains('cap');
          var orphanFigure = last.tagName === 'FIGURE' &&
            carry[0].classList.contains('cap');
          if (!heading && !caption && !orphanFigure) break;
          current.pop();
          measC.removeChild(last);
          carry.unshift(last);
        }
        // The carry-back must never empty the page: putting everything back on
        // a fresh page reproduces the same overflow, and the block that did not
        // fit ends up clipped. Give the leading blocks back (a figure together
        // with its caption) until the page holds something again.
        while (!current.length && carry.length > 1) {
          var give = carry.shift();
          measC.appendChild(give);
          current.push(give);
          if (give.tagName === 'FIGURE' && carry.length > 1 &&
              carry[0].classList.contains('cap')) {
            var cap = carry.shift();
            measC.appendChild(cap);
            current.push(cap);
          }
        }
        closePage();
        for (var c = 0; c < carry.length; c++) {
          measC.appendChild(carry[c]);
          current.push(carry[c]);
        }

        // The carried group can itself be taller than a page — a figure, its
        // caption, a heading and a listing all travel together and then do not
        // fit. Peel blocks off the end (taking any heading above them, so it is
        // not stranded) until what remains fits, closing a page each time.
        while (!fits() && current.length > 1) {
          var tail = [current.pop()];
          measC.removeChild(tail[0]);
          while (current.length > 1 &&
              /^H[23]$/.test(current[current.length - 1].tagName)) {
            var head = current.pop();
            measC.removeChild(head);
            tail.unshift(head);
          }
          closePage();
          for (var k = 0; k < tail.length; k++) {
            measC.appendChild(tail[k]);
            current.push(tail[k]);
          }
        }
        // A single block taller than a page (a big figure) still overflows its
        // page rather than vanishing — clipping is visible, dropping is not.
      }
    }
    closePage();
    measC.innerHTML = '';

    // --- table of contents --------------------------------------------------

    // Built after the flow so it can carry real page numbers, then spliced in
    // right after the title page — which shifts every later page by the number
    // of TOC pages, so the numbers are computed against the final offset.
    (function buildToc() {
      var rows = [];
      for (var p = 0; p < pages.length; p++) {
        if (!/class="[^"]*ch-open/.test(pages[p].html)) continue;
        rows.push({ n: pages[p].chapter, title: pages[p].title, part: pages[p].part, at: p });
      }
      if (!rows.length) return;

      var insertAt = 0;
      for (var q = 0; q < pages.length; q++) {
        if (pages[q].kind === 'title') { insertAt = q + 1; break; }
      }

      function render(list, shift) {
        var h = '<div class="toc"><h2>' + esc(t('toc', 'Contents')) + '</h2>';
        var lastPart = null;
        for (var r = 0; r < list.length; r++) {
          var row = list[r];
          if (row.part && row.part !== lastPart) {
            h += '<div class="toc-part">' + esc(row.part) + '</div>';
            lastPart = row.part;
          }
          h += '<div class="toc-row" data-goto="' + (row.at + shift) + '">' +
            '<span class="n">' + (row.n || '') + '</span>' +
            '<span class="t">' + esc(row.title) + '</span>' +
            '<span class="pg">' + (row.at + shift + 1) + '</span></div>';
        }
        return h + '</div>';
      }

      // How many rows fit is a property of the page box — and on a phone the
      // box is whatever the screen gives us — so the contents is filled by
      // measurement like every other page rather than by a constant that
      // happened to be right for one paper size.
      var probe = document.createElement('div');
      var chunks = [], from = 0, guard = 0;
      while (from < rows.length && guard++ < 200) {
        var take = 0;
        while (from + take < rows.length) {
          probe.innerHTML = render(rows.slice(from, from + take + 1), 0);
          if (!fitsAlone(probe.firstChild)) break;
          take++;
        }
        if (take === 0) take = 1;   // a row taller than the page: keep going
        chunks.push(rows.slice(from, from + take));
        from += take;
      }
      // The contents should open on a recto (even index) like a chapter does,
      // and the total number of inserted pages must stay even — the flow
      // already placed every chapter opener on a recto, and an odd insertion
      // would shift all of them onto the wrong side. Neither holds without
      // facing pages.
      var lead = (single || insertAt % 2 === 0) ? 0 : 1;
      if (!single) {
        while ((lead + chunks.length) % 2 !== 0) chunks.push(null);
      }

      var shiftBy = lead + chunks.length;
      var built = [];
      if (lead) built.push({ html: '', kind: 'blank', chapter: 0, title: '', part: '' });
      chunks.forEach(function (chunk) {
        built.push({
          html: chunk ? render(chunk, shiftBy) : '',
          kind: chunk ? 'toc' : 'blank',
          chapter: 0, title: '', part: ''
        });
      });
      pages.splice.apply(pages, [insertAt, 0].concat(built));
    })();

    indexChapters();
    // Spread 0 is the closed book either way; past it a spread is two pages
    // wide, or one.
    maxSpread = single ? pages.length : Math.ceil((pages.length + 1) / 2);
  }

  function esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  // --- the spread -----------------------------------------------------------
  //
  // Exactly two pages exist in the DOM at any moment: the left and right of the
  // current spread. There is no 3D, no stack of sheets, and no z-index
  // bookkeeping — a stack of a hundred composited layers is what made stale
  // pages bleed through the current one, and it bought nothing a reader of a
  // 300-page reference wants. Turning a page is a synchronous re-render, so
  // what is on screen is always what the page indicator says.

  var book = document.getElementById('book');
  var sheetsEl = document.getElementById('sheets');

  var leftSlot = document.createElement('div');
  leftSlot.className = 'page-slot left';
  var rightSlot = document.createElement('div');
  rightSlot.className = 'page-slot right';
  var coverSlot = document.createElement('div');
  coverSlot.className = 'book-cover';
  coverSlot.innerHTML = document.getElementById('cover-art').innerHTML;

  sheetsEl.appendChild(leftSlot);
  sheetsEl.appendChild(rightSlot);
  sheetsEl.appendChild(coverSlot);

  function pageHtml(idx) {
    var pg = pages[idx];
    if (!pg) return '';
    var cls = 'page' + (pg.kind === 'title' ? ' cover-full' : '');
    var no = (pg.kind === 'title' || pg.kind === 'blank') ? '' :
      '<div class="pageno ' + (idx % 2 === 0 ? 'r' : 'l') + '">' +
      (idx + 1) + '</div>';
    return '<div class="' + cls + '"><div class="page-content">' +
      pg.html + '</div>' + no + '</div>';
  }

  // Spread 0 is the closed book. Spread s ≥ 1 shows pages[2s-3] on the left
  // (nothing for s = 1) and pages[2s-2] on the right, which keeps even page
  // indices on the recto exactly as the flow assumed. Single-page mode has no
  // left-hand page at all: spread s is simply pages[s-1].
  var maxSpread = 0;   // buildPages() sets it: it depends on the mode
  var spread = 0;

  function leftIndex() { return single ? -1 : 2 * spread - 3; }
  function rightIndex() { return single ? spread - 1 : 2 * spread - 2; }

  // --- position, in terms every edition shares ------------------------------
  //
  // Page numbers are a property of the translation: Korean sets shorter, so
  // the same sentence is on a different page. What every edition does share is
  // the chapter and how far into it you are, and that is what the location
  // hash carries (`#ch7-3` = chapter 7, its 3rd page) — so switching language
  // lands on the same content instead of the same page number.

  var chapterStarts = {}; // chapter number → index of its opening page
  function indexChapters() {
    chapterStarts = {};
    for (var ci = 0; ci < pages.length; ci++) {
      var chNo = pages[ci].chapter;
      if (chapterStarts[chNo] == null &&
          /class="[^"]*ch-open/.test(pages[ci].html)) {
        chapterStarts[chNo] = ci;
      }
    }
  }

  function anchorFor(idx) {
    var pg = pages[idx];
    if (!pg) return '';
    var start = chapterStarts[pg.chapter];
    if (pg.chapter > 0 && start != null) {
      return 'ch' + pg.chapter + '-' + (idx - start + 1);
    }
    return 'front-' + (idx + 1); // preface, contents, appendix openers
  }

  function indexForAnchor(hash) {
    var m = /^#ch(\d+)(?:-(\d+))?$/.exec(hash);
    if (m) {
      var start = chapterStarts[parseInt(m[1], 10)];
      if (start == null) return null;
      var want = start + (m[2] ? parseInt(m[2], 10) - 1 : 0);
      // Clamp inside the chapter: a shorter translation must not spill into
      // the next one.
      var end = pages.length - 1;
      for (var j = start + 1; j < pages.length; j++) {
        if (/class="[^"]*ch-open/.test(pages[j].html)) { end = j - 1; break; }
      }
      return Math.max(start, Math.min(end, want));
    }
    var f = /^#front-(\d+)$/.exec(hash);
    if (f) return Math.max(0, Math.min(pages.length - 1, parseInt(f[1], 10) - 1));
    return null;
  }

  // Where the reader is, in the terms above — '' while the book is shut. It is
  // also what survives a reflow: page numbers change with the page box, the
  // anchor does not.
  function currentAnchor() {
    var idx = leftIndex() >= 0 ? leftIndex() : rightIndex();
    if (spread === 0 || idx < 0 || idx >= pages.length) return '';
    return anchorFor(idx);
  }

  function rememberPosition() {
    var anchor = currentAnchor();
    if (anchor && history.replaceState) {
      history.replaceState(null, '', '#' + anchor);
    }
  }

  function render(direction) {
    var closed = spread === 0;
    book.classList.toggle('closed', closed);
    coverSlot.hidden = !closed;
    leftSlot.hidden = closed;
    rightSlot.hidden = closed;

    if (!closed) {
      leftSlot.innerHTML = pageHtml(leftIndex());
      rightSlot.innerHTML = pageHtml(rightIndex());
      // Re-rendering discards DOM state, so anything the reader owns — their
      // edits — is re-applied from the store that outlives the slots.
      markEdits(sheetsEl);
    }
    rememberPosition();

    // A short, non-blocking hint of movement. It restarts on every turn and
    // cannot leave stale pixels behind: the content is already in place before
    // the animation begins.
    if (direction) {
      var cls = direction > 0 ? 'turn-fwd' : 'turn-back';
      [leftSlot, rightSlot].forEach(function (el) {
        el.classList.remove('turn-fwd', 'turn-back');
        void el.offsetWidth;
        el.classList.add(cls);
      });
    }
    update();
  }

  function goToSpread(s, direction) {
    s = Math.max(0, Math.min(maxSpread, s));
    if (s === spread && direction) return;
    spread = s;
    render(direction);
  }

  function next() { goToSpread(spread + 1, 1); }
  function prev() { goToSpread(spread - 1, -1); }

  function goToPage(idx) {
    if (single) { goToSpread(idx + 1, 1); return; }
    // Even indices sit on the right of their spread, odd ones on the left.
    goToSpread(idx % 2 === 0 ? idx / 2 + 1 : (idx + 3) / 2, 1);
  }

  var hud = document.getElementById('page-indicator');
  var navPrev = document.getElementById('nav-prev');
  var navNext = document.getElementById('nav-next');
  var gotoBtn = document.getElementById('goto-btn');
  var langBtn = document.getElementById('lang-btn');
  var crumbEl = document.getElementById('book-crumb');

  function update() {
    var shown = [];
    var l = leftIndex(), r = rightIndex();
    if (spread > 0) {
      if (l >= 0 && l < pages.length) shown.push(l + 1);
      if (r >= 0 && r < pages.length) shown.push(r + 1);
    }
    var where = shown.length ? shown.join('–') + ' / ' + pages.length : '';
    if (hud) hud.textContent = where;
    // In single-page mode the picker button carries the position: the bar has
    // room for three controls and nothing else.
    gotoBtn.textContent = where || t('goto', 'Go to page');
    // Which chapter this is — the one thing a spread showed for free and a
    // single page does not.
    var here = pages[r >= 0 ? r : 0];
    crumbEl.textContent = (spread > 0 && here && here.chapter > 0)
      ? here.chapter + ' · ' + here.title : '';
    navPrev.disabled = spread <= 0;
    navNext.disabled = spread >= maxSpread;
  }

  navPrev.addEventListener('click', prev);
  navNext.addEventListener('click', next);
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && sheetOpen()) { closeSheet(); return; }
    if (e.target && /INPUT|TEXTAREA/.test(e.target.tagName)) return;
    if (sheetOpen()) return;
    if (overlayOpen()) {
      // The editor owns the keyboard while it is up.
      if (e.key === 'Escape') closeOverlay();
      return;
    }
    if (e.key === 'ArrowRight' || e.key === 'PageDown') { next(); e.preventDefault(); }
    if (e.key === 'ArrowLeft' || e.key === 'PageUp') { prev(); e.preventDefault(); }
  });

  var tocBtn = document.getElementById('toc-btn');
  if (tocBtn) {
    tocBtn.addEventListener('click', function () {
      for (var p = 0; p < pages.length; p++) {
        if (pages[p].kind === 'toc') { goToPage(p); return; }
      }
    });
  }

  document.addEventListener('click', function (e) {
    var row = e.target.closest && e.target.closest('.toc-row');
    if (row) goToPage(parseInt(row.getAttribute('data-goto'), 10));
  });

  // --- the page picker ------------------------------------------------------
  //
  // With one page on screen the reader loses the spread's sense of place, and
  // a phone has no keyboard to type a page number into. The middle button of
  // the bar opens a sheet that answers both: the chapters, with the page each
  // starts on, and a box to jump to a number directly.

  var sheet = buildSheet();
  var langSheet = buildLangSheet();

  function buildSheet() {
    var el = document.createElement('div');
    el.className = 'goto-sheet';
    el.hidden = true;
    el.innerHTML =
      '<div class="goto-panel" role="dialog" aria-modal="true">' +
        '<div class="goto-bar">' +
          '<span class="goto-title"></span>' +
          '<button class="goto-close" type="button">✕</button>' +
        '</div>' +
        '<form class="goto-form">' +
          '<input class="goto-input" type="number" inputmode="numeric" ' +
            'min="1" step="1">' +
          '<button class="goto-submit" type="submit"></button>' +
        '</form>' +
        '<div class="goto-list"></div>' +
      '</div>';
    document.body.appendChild(el);

    el.querySelector('.goto-title').textContent = t('goto', 'Go to page');
    el.querySelector('.goto-submit').textContent = t('go', 'Go');
    var close = el.querySelector('.goto-close');
    close.setAttribute('aria-label', t('close', 'Close'));
    close.addEventListener('click', closeSheet);
    el.addEventListener('click', function (e) {
      if (e.target === el) closeSheet();
    });

    el.querySelector('.goto-form').addEventListener('submit', function (e) {
      e.preventDefault();
      var box = el.querySelector('.goto-input');
      var n = parseInt(box.value, 10);
      if (!n) return;
      goToPage(Math.max(1, Math.min(pages.length, n)) - 1);
      closeSheet();
    });

    el.querySelector('.goto-list').addEventListener('click', function (e) {
      var row = e.target.closest && e.target.closest('.goto-row');
      if (!row) return;
      goToPage(parseInt(row.getAttribute('data-goto'), 10));
      closeSheet();
    });
    return el;
  }

  // Rebuilt with the pages: a reflow moves every chapter to a new page number.
  function fillSheet() {
    var box = sheet.querySelector('.goto-input');
    box.max = String(pages.length);
    box.placeholder = '1–' + pages.length;

    var h = '', lastPart = null, tocAt = -1;
    for (var p = 0; p < pages.length; p++) {
      if (tocAt < 0 && pages[p].kind === 'toc') tocAt = p;
      if (!/class="[^"]*ch-open/.test(pages[p].html)) continue;
      if (pages[p].part && pages[p].part !== lastPart) {
        lastPart = pages[p].part;
        h += '<div class="goto-part">' + esc(lastPart) + '</div>';
      }
      h += row(p, pages[p].chapter || '', pages[p].title);
    }
    if (tocAt >= 0) h = row(tocAt, '', t('toc', 'Contents')) + h;
    sheet.querySelector('.goto-list').innerHTML = h;

    function row(at, n, title) {
      return '<button class="goto-row" type="button" data-goto="' + at + '">' +
        '<span class="n">' + esc(n) + '</span>' +
        '<span class="t">' + esc(title) + '</span>' +
        '<span class="pg">' + (at + 1) + '</span></button>';
    }
  }

  function openSheet() {
    var idx = rightIndex();
    var here = (spread > 0 && idx >= 0 && idx < pages.length) ? pages[idx] : null;
    var box = sheet.querySelector('.goto-input');
    box.value = here ? idx + 1 : '';
    // Deliberately not focused: on a phone the keyboard would come up over
    // the chapter list, which is the faster way to move.
    sheet.hidden = false;
    // Open the list at the chapter being read, not at the top of the book.
    // Only a numbered chapter can be pointed at: chapter 0 is every page that
    // belongs to no chapter — the preface and all three appendices.
    var at = (here && here.chapter > 0) ? chapterStarts[here.chapter] : null;
    var was = sheet.querySelector('.goto-row[aria-current]');
    if (was) was.removeAttribute('aria-current');
    var row = at == null ? null :
      sheet.querySelector('.goto-row[data-goto="' + at + '"]');
    if (!row) return;
    row.setAttribute('aria-current', 'true');
    if (row.scrollIntoView) row.scrollIntoView({ block: 'center' });
  }

  // The language list is the same sheet in a shorter form: on a phone the row
  // of editions along the foot of a spread is six 11px links side by side, and
  // nobody can hit one of those.
  function buildLangSheet() {
    var el = document.createElement('div');
    el.className = 'goto-sheet lang-sheet';
    el.hidden = true;
    el.innerHTML =
      '<div class="goto-panel" role="dialog" aria-modal="true">' +
        '<div class="goto-bar">' +
          '<span class="goto-title"></span>' +
          '<button class="goto-close" type="button">✕</button>' +
        '</div>' +
        '<div class="lang-body"></div>' +
      '</div>';
    document.body.appendChild(el);

    el.querySelector('.goto-title').textContent = t('lang', 'Language');
    var close = el.querySelector('.goto-close');
    close.setAttribute('aria-label', t('close', 'Close'));
    close.addEventListener('click', closeSheet);
    el.addEventListener('click', function (e) {
      if (e.target === el) closeSheet();
    });
    // A language link navigates, so the sheet needs no handler of its own —
    // the anchors already rewrite their href to carry the reading position.
    return el;
  }

  function closeSheet() {
    sheet.hidden = true;
    langSheet.hidden = true;
  }
  function sheetOpen() { return !sheet.hidden || !langSheet.hidden; }

  gotoBtn.addEventListener('click', openSheet);
  langBtn.addEventListener('click', function () { langSheet.hidden = false; });

  // --- layout ---------------------------------------------------------------

  var langs = document.querySelector('.book-langs');
  var note = document.querySelector('.book-note');

  // The controls live in different places in the two modes. On a full-bleed
  // page the side arrows would sit on top of the text, so they join the picker
  // in a bar under the paper; the language links and the translation notice
  // move into the sheet, which is the only place left with room for them.
  function applyChrome() {
    if (single) {
      // back · picker · language · forward, in that order.
      hudEl.insertBefore(navNext, hudEl.firstChild);
      hudEl.insertBefore(langBtn, navNext);
      hudEl.insertBefore(gotoBtn, langBtn);
      hudEl.insertBefore(navPrev, gotoBtn);
      var body = langSheet.querySelector('.lang-body');
      if (langs) body.appendChild(langs);
      // The translation notice belongs with the editions it is about.
      if (note) body.appendChild(note);
    } else {
      stage.appendChild(navPrev);
      stage.appendChild(navNext);
      hudEl.appendChild(gotoBtn);
      hudEl.appendChild(langBtn);
      if (note) hudEl.appendChild(note);
      if (langs) hudEl.appendChild(langs);
    }
  }

  function rescale() {
    if (single) {
      // Nothing to scale: the page was measured to fit the screen it is on.
      scaler.style.transform = '';
      return;
    }
    // The stage is the whole viewport (the page carries no other chrome), so
    // there is nothing to subtract and nothing to keep in sync.
    var w = stage.clientWidth, h = stage.clientHeight;
    var s = Math.min((w - 70) / (PW * 2 + 40), (h - 60) / (PH + 24));
    scaler.style.transform = 'scale(' + Math.max(0.28, Math.min(s, 1.1)) + ')';
  }

  // A resize that changes the page box invalidates every page break, so the
  // flow runs again and the reader is put back where they were — by anchor,
  // since the page they were on now has a different number.
  function relayout() {
    // Read the position first: measureGeometry() can flip the mode, and the
    // spread arithmetic that answers "which page is this" flips with it.
    var anchor = currentAnchor();
    var wasSingle = single, w = PW, h = PH;
    measureGeometry();
    if (single === wasSingle && PW === w && PH === h) { rescale(); return; }
    applyChrome();
    // The bar changes height with the mode; measure again now that it has.
    measureGeometry();
    buildPages();
    fillSheet();
    var idx = anchor ? indexForAnchor('#' + anchor) : null;
    spread = 0;
    if (idx == null) render(0); else goToPage(idx);
    rescale();
  }

  var resizeTimer = null;
  addEventListener('resize', function () {
    clearTimeout(resizeTimer);
    // Reflowing 300 pages is not something to do per resize event, and mobile
    // browsers fire one for every step of a collapsing toolbar.
    resizeTimer = setTimeout(relayout, 180);
  });

  measureGeometry();
  applyChrome();
  measureGeometry();   // the bar is in place now, so the page box is final
  buildPages();
  fillSheet();
  render(0);
  rescale();

  // Turning pages by swiping: on a phone the bar is not the only thing a
  // reader reaches for. Vertical drags are left alone — output popovers and
  // the picker scroll.
  var touchX = 0, touchY = 0, touching = false;
  stage.addEventListener('touchstart', function (e) {
    if (e.touches.length !== 1) { touching = false; return; }
    touching = true;
    touchX = e.touches[0].clientX;
    touchY = e.touches[0].clientY;
  }, { passive: true });
  stage.addEventListener('touchend', function (e) {
    if (!touching || !e.changedTouches.length) return;
    touching = false;
    var dx = e.changedTouches[0].clientX - touchX;
    var dy = e.changedTouches[0].clientY - touchY;
    if (Math.abs(dx) < 60 || Math.abs(dx) < Math.abs(dy) * 1.5) return;
    if (dx < 0) next(); else prev();
  }, { passive: true });

  // --- running and editing code ---------------------------------------------

  // Compiling and executing is the site playground's job; the book supplies the
  // program text, a build-time artifact id when the listing is untouched, and
  // somewhere to put the output.

  function sourceOf(pre) {
    return [].slice.call(pre.querySelectorAll('.cl'))
      .map(function (n) { return n.textContent; }).join('\n');
  }

  // Reader edits cannot live in the DOM: turning a page re-renders the slot
  // from the stored HTML, so anything typed into it would vanish. They are
  // keyed by chapter and listing number, which survive re-rendering.
  var edits = {};
  function keyOf(wrap) {
    return wrap.getAttribute('data-ch') + ':' + wrap.getAttribute('data-idx');
  }

  // Every listing in the book is a complete program, so the printed text is
  // exactly what gets compiled — that is what lets the build precompile it.
  // A listing split across pages keeps the whole program on the wrapper;
  // running only the visible slice would compile half a file.
  function programFor(wrap) {
    var key = keyOf(wrap);
    if (edits[key] != null) return edits[key];
    return wrap.getAttribute('data-src') ||
      sourceOf(wrap.querySelector('pre.code'));
  }

  function originalFor(wrap) {
    return wrap.getAttribute('data-src') ||
      sourceOf(wrap.querySelector('pre.code'));
  }

  // Marks listings a reader has edited, after every re-render.
  function markEdits(root) {
    [].forEach.call(root.querySelectorAll('.runwrap'), function (w) {
      if (edits[keyOf(w)] != null) {
        w.setAttribute('data-edited', '1');
        var bar = w.querySelector('.runbar');
        if (bar) bar.setAttribute('data-edited-label', t('edited', 'edited'));
      } else {
        w.removeAttribute('data-edited');
      }
    });
  }

  function runInto(wrap, source, prebuiltId, ui) {
    var engine = window.FxDartPlayground;
    ui.log.textContent = '';
    ui.out.hidden = true;
    if (!engine) {
      ui.out.hidden = false;
      ui.log.textContent = t('runUnavailable', 'The run engine failed to load.');
      return;
    }
    ui.button.disabled = true;
    ui.status.textContent = t('compiling', 'Compiling…');
    var got = false;
    engine.run(source, {
      onStart: function () {
        ui.status.textContent = t('running', 'Running…');
        ui.out.hidden = false;
      },
      onOutput: function (text, isError) {
        got = true;
        ui.out.hidden = false;
        ui.log.textContent += (isError ? '⚠ ' : '') + text + '\n';
      },
      onDone: function () {
        ui.status.textContent = '';
        ui.button.disabled = false;
        setTimeout(function () {
          if (!got) ui.log.textContent = t('noOutput', '(no output)');
        }, 2500);
      },
      onError: function (message) {
        ui.status.textContent = '';
        ui.button.disabled = false;
        ui.out.hidden = false;
        ui.log.textContent = message;
      }
    }, { prebuiltId: prebuiltId });
  }

  // --- the editor overlay ---------------------------------------------------
  //
  // A book page is a fixed box, so edits do not happen in place: the ✎ button
  // opens the whole program in an overlay with room for the code, the output
  // and a reset. The printed page keeps showing the published listing, and an
  // edited one is badged so the difference is never silent.

  var overlay = null, overlayWrap = null;

  function buildOverlay() {
    var el = document.createElement('div');
    el.className = 'editor-overlay';
    el.hidden = true;
    el.innerHTML =
      '<div class="editor-panel" role="dialog" aria-modal="true">' +
        '<div class="editor-bar">' +
          '<span class="editor-title"></span>' +
          '<button class="editor-close" type="button">✕</button>' +
        '</div>' +
        '<textarea class="editor-code" spellcheck="false"></textarea>' +
        '<div class="editor-tools">' +
          '<button class="editor-run" type="button"></button>' +
          '<button class="editor-reset" type="button"></button>' +
          '<span class="editor-status"></span>' +
        '</div>' +
        '<div class="editor-out" hidden><pre class="editor-log"></pre></div>' +
      '</div>';
    document.body.appendChild(el);

    el.querySelector('.editor-close').addEventListener('click', closeOverlay);
    el.addEventListener('click', function (e) {
      if (e.target === el) closeOverlay();
    });

    var area = el.querySelector('.editor-code');
    // Tab indents instead of leaving the field: this is a code editor.
    area.addEventListener('keydown', function (e) {
      if (e.key !== 'Tab') return;
      e.preventDefault();
      var s = area.selectionStart, t2 = area.selectionEnd;
      area.value = area.value.slice(0, s) + '  ' + area.value.slice(t2);
      area.selectionStart = area.selectionEnd = s + 2;
    });
    area.addEventListener('input', function () {
      if (!overlayWrap) return;
      var key = keyOf(overlayWrap);
      if (area.value === originalFor(overlayWrap)) delete edits[key];
      else edits[key] = area.value;
      markEdits(document);
      el.querySelector('.editor-reset').disabled = edits[key] == null;
    });

    el.querySelector('.editor-run').addEventListener('click', function () {
      if (!overlayWrap) return;
      var edited = edits[keyOf(overlayWrap)] != null;
      runInto(overlayWrap, area.value,
        edited ? null : overlayWrap.getAttribute('data-pg'), {
          button: el.querySelector('.editor-run'),
          status: el.querySelector('.editor-status'),
          out: el.querySelector('.editor-out'),
          log: el.querySelector('.editor-log')
        });
    });

    el.querySelector('.editor-reset').addEventListener('click', function () {
      if (!overlayWrap) return;
      delete edits[keyOf(overlayWrap)];
      area.value = originalFor(overlayWrap);
      el.querySelector('.editor-reset').disabled = true;
      markEdits(document);
    });

    return el;
  }

  function openOverlay(wrap) {
    overlay = overlay || buildOverlay();
    overlayWrap = wrap;
    var key = keyOf(wrap);
    overlay.querySelector('.editor-title').textContent =
      t('editTitle', 'Edit and run');
    overlay.querySelector('.editor-run').textContent = t('run', '▶ Run');
    overlay.querySelector('.editor-reset').textContent = t('reset', 'Reset');
    overlay.querySelector('.editor-reset').disabled = edits[key] == null;
    overlay.querySelector('.editor-code').value = programFor(wrap);
    overlay.querySelector('.editor-out').hidden = true;
    overlay.querySelector('.editor-log').textContent = '';
    overlay.querySelector('.editor-status').textContent = '';
    overlay.hidden = false;
    var area = overlay.querySelector('.editor-code');
    area.focus();
    // Focusing a filled textarea can leave the caret at the end, which scrolls
    // the listing out of view; open at line 1 like an editor would.
    area.setSelectionRange(0, 0);
    area.scrollTop = 0;
  }

  function closeOverlay() {
    if (overlay) overlay.hidden = true;
    overlayWrap = null;
  }

  function overlayOpen() { return overlay && !overlay.hidden; }

  document.addEventListener('click', function (e) {
    if (!e.target.closest) return;

    var closeBtn = e.target.closest('.run-close');
    if (closeBtn) {
      closeBtn.closest('.runwrap').querySelector('.run-out').hidden = true;
      return;
    }

    var editBtn = e.target.closest('.edit-btn');
    if (editBtn) {
      openOverlay(editBtn.closest('.runwrap'));
      return;
    }

    var btn = e.target.closest('.run-btn');
    if (!btn) return;
    var wrap = btn.closest('.runwrap');
    var edited = edits[keyOf(wrap)] != null;
    runInto(wrap, programFor(wrap),
      // A build-time artifact is only valid for the published text.
      edited ? null : wrap.getAttribute('data-pg'), {
        button: btn,
        status: wrap.querySelector('.run-status'),
        out: wrap.querySelector('.run-out'),
        log: wrap.querySelector('.run-log')
      });
  });

  // Booting the runtime costs a 17MB download, so it waits until a page with
  // runnable code is actually in front of the reader — then warms up while
  // they read it, so the click that follows is not the one that pays.
  var warmed = false;
  function armPrewarm(root) {
    if (warmed || !window.FxDartPlayground) return;
    if (!root.querySelectorAll('.run-btn').length) return;
    warmed = true;
    setTimeout(function () { window.FxDartPlayground.prewarm(); }, 400);
  }
  // Pages mount lazily, so arm on whatever comes on screen.
  var mo = new MutationObserver(function (records) {
    records.forEach(function (r) {
      [].forEach.call(r.addedNodes, function (n) {
        if (n.nodeType === 1) armPrewarm(n);
      });
    });
  });
  mo.observe(sheetsEl, { childList: true, subtree: true });
  armPrewarm(document);

  // Deep link: #ch3 opens the book at chapter 3.
  // Deep link: #ch3 opens chapter 3, #ch3-5 its fifth page, #front-7 a page
  // before chapter 1. The same anchors are what the language links carry.
  (function openHash() {
    var idx = indexForAnchor(location.hash || '');
    if (idx != null) goToPage(idx);
  })();

  // Switching language keeps your place: the anchor travels with the link, and
  // the other edition resolves it against its own pagination. Only the edition
  // links — the switcher's last row leaves the book for the translation guide,
  // and a reading position means nothing there.
  [].forEach.call(
    document.querySelectorAll('.book-langs a[hreflang]'),
    function (a) {
      a.addEventListener('click', function () {
        var anchor = currentAnchor();
        if (!anchor) return;
        a.href = a.href.split('#')[0] + '#' + anchor;
      });
    }
  );
})();
