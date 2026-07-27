---
slug: parallel-downloads
title: Parallel downloads, results in order — Dart vs FxDart
description: Six downloads with different speeds, 3 at a time — concurrent keeps request order even when completions interleave, vs pool bookkeeping.
heading: Parallel downloads, results in order
order: 46
tier: 4
functions: toAsync, map, concurrent, zipWithIndex, join, sumBy
domain: general
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Download six files — each with a fixed size and a fixed (simulated)
    transfer time, in the code below — with at most <strong>three
    downloads in flight</strong>, and list the results numbered
    <strong>in request order</strong>. The delays are chosen so completions
    interleave: the 30&nbsp;ms <code>video.mp4</code> is requested first
    but the 10&nbsp;ms <code>notes.txt</code> finishes first. Both versions
    print which file finished first and the maximum observed concurrency —
    proving the work really overlapped, out of order, while the listing
    stayed in order.
  </p>
  <p>
    That reorder-under-the-hood, order-on-the-surface guarantee is exactly
    what <code>concurrent(3)</code> does: it evaluates up to three upstream
    items at once and still yields results in source order. The chain
    numbers them with <code>zipWithIndex</code> and assembles the report
    with <code>join</code>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    <code>Future.wait</code> preserves order but downloads everything at
    once — no limit. Adding the limit is what forces the native worker
    pool, and preserving order under that pool is precisely the subtle
    part: the pre-sized <code>results</code> list indexed by a shared
    cursor. Get the slot bookkeeping wrong and results come back shuffled —
    a bug that only shows when completion order happens to differ from
    request order, which is timing-dependent and easy to miss in tests. In
    FxDart the ordering guarantee is the operator's contract, not your
    code: <code>concurrent(3)</code> cannot return items out of order, no
    matter how the timings fall.
  </p>
