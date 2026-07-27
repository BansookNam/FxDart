/* Dart-vs-FxDart TOC filtering.
 *
 * The filter bar is rendered by tool/build_docs.dart with `hidden` set, so a
 * reader without JS simply sees the full list. This file un-hides it and
 * wires the behavior: one mode button (all / async / a verdict) plus a text
 * box matching against each row's data-fns function list. Tiers with no
 * visible rows hide as a whole.
 */
(function () {
  'use strict';

  function init() {
    var bar = document.querySelector('.cmp-filter');
    if (!bar) return;
    bar.hidden = false;

    var input = bar.querySelector('input');
    var buttons = [].slice.call(bar.querySelectorAll('button'));
    var mode = 'all';

    function apply() {
      var q = (input.value || '').trim().toLowerCase();
      document.querySelectorAll('.cmp-list > li').forEach(function (li) {
        var okMode = mode === 'all' ||
          (mode === 'async'
            ? li.getAttribute('data-async') === 'true'
            : li.getAttribute('data-verdict') === mode);
        var okQuery = !q ||
          (li.getAttribute('data-fns') || '').toLowerCase().indexOf(q) !== -1;
        li.style.display = okMode && okQuery ? '' : 'none';
      });
      document.querySelectorAll('.cmp-tier').forEach(function (sec) {
        var any = [].slice.call(sec.querySelectorAll('.cmp-list > li'))
          .some(function (li) { return li.style.display !== 'none'; });
        sec.style.display = any ? '' : 'none';
      });
    }

    buttons.forEach(function (b) {
      b.addEventListener('click', function () {
        mode = b.getAttribute('data-filter');
        buttons.forEach(function (x) { x.classList.toggle('active', x === b); });
        apply();
      });
    });
    input.addEventListener('input', apply);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
