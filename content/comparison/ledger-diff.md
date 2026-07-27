---
slug: ledger-diff
title: Diff two ledger snapshots — Dart vs FxDart
description: Added, removed, and unchanged entries between two snapshots — differenceBy and intersectionBy by id vs hand-built id sets and where filters.
heading: Diff two ledger snapshots
order: 40
tier: 4
functions: differenceBy, intersectionBy, sortBy, map, concat, size, sumBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Two snapshots of the same ledger (data in the code): a sync happened in
    between, and entries were added and removed. Print a diff keyed by
    entry id — <code>+</code> lines for added entries, <code>-</code> lines
    for removed ones (each section sorted by id), the count of unchanged
    entries, and the net change in total amount. Both versions must print
    the diff under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Diffing is set algebra over a key, and FxDart ships the vocabulary:
    <code>differenceBy</code> called both ways gives added and removed,
    <code>intersectionBy</code> gives the unchanged entries — three
    declarations that read like the definition of a diff. The
    <code>sortBy</code> → <code>map</code> → <code>concat</code> pipeline
    then renders both sections in one expression. Native Dart has set
    operations only for <code>Set</code> itself, not for "by this key of
    these objects", so the honest version manually projects id sets and
    writes a negated <code>contains</code> filter per direction — easy to
    get backwards, and the intent ("what's in B but not A?") lives in the
    predicate's polarity rather than in a function name.
  </p>
