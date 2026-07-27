---
slug: paginate-users
title: Batch users into pages of 10 — Dart vs FxDart
description: Split a user list into fixed-size pages — slices from package:collection vs chunk + map in FxDart.
heading: Batch users into pages of 10
order: 8
tier: 1
functions: chunk, map
alsoLink: concurrent
domain: users
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Split twelve users into <strong>pages of 10</strong> (the last page may
    be short) and print each page on one line with its number, size, and
    names. The data is in the code below; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Core Dart has no chunking at all — without help this is an index loop
    over <code>sublist</code> with a <code>min</code> guard for the short
    last page. <code>package:collection</code>'s <code>slices</code> fixes
    that, and if you already depend on it the two panels are nearly twins.
    FxDart's edge is that <code>chunk</code> needs no extra dependency, is
    lazy (pages materialize as you consume them), and the very same step
    works on async chains — batching requests before a
    <code>concurrent</code> stage is the classic use. A modest win, but a
    real one.
  </p>
