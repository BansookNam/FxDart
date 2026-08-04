---
slug: spend-by-category-rx
title: Spend grouped by category — RxDart vs FxDart
description: Per-category totals in first-seen order — a stream of GroupedStreams folded and merged back together vs a groupBy that just returns a Map.
heading: Spend grouped by category
order: 17
tier: 2
functions: fx, groupedBy, map, sumBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Total nine August transactions <strong>per category</strong>, and
    print the totals in the order each category first appears in the
    statement. The data is in the code; both versions must print the
    lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Grouping is where the push model's commitment to "everything is a
    stream" gets expensive. RxDart's <code>groupBy</code> cannot return a
    map — the source may never end — so it returns a
    <em>stream of streams</em>: one <code>GroupedStream</code> per new
    key. To get totals out, each inner stream must be folded (a
    <code>Future</code>), the future lifted back into a stream
    (<code>asStream</code>), and the results merged with
    <code>flatMap</code> — three layers of plumbing around one
    <code>sum</code>. (A pragmatic rx user can dodge <code>groupBy</code>
    entirely by folding the whole stream into a mutable map — shorter,
    but it abandons the operator this example is about and the grouping
    becomes imperative again.) And the shape has sharp edges: fold with
    <code>asyncExpand</code> instead of <code>flatMap</code> and the
    program deadlocks, because pausing the outer stream while waiting
    for a group total stops the source that must complete before any
    group can close.
  </p>
  <p>
    FxDart's data is finite by construction, so grouping needs no
    streams-of-streams: <code>groupedBy</code> yields plain
    <code>(key, items)</code> records in first-seen key order and the
    chain keeps going, with <code>sumBy</code> doing the arithmetic per
    group. Nothing is deferred because nothing is still arriving. For live, unbounded feeds the GroupedStream design is the
    right call — but for a statement that is already at hand, this is
    a pull-shaped job and the pull version says so in three lines.
    The verdict goes to FxDart.
  </p>
