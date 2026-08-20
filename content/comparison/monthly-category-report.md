---
slug: monthly-category-report
title: Monthly category report, sorted by spend — Dart vs FxDart
description: Filter a ledger to one month, total each category, and rank them — loop plus mutable map in plain Dart vs filter + groupBy + sortBy in FxDart.
heading: Monthly category report, sorted by spend
order: 29
tier: 3
functions: filter, groupBy, map, sortBy, join, foldByOrSkip
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    From a ledger that spills over from June into July 2026, build the July
    spending report: keep only July transactions, total each category, and
    print one line per category — <strong>biggest spend first</strong>. The
    data is in the code below; both versions must print the lines shown
    under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Native Dart has no <code>groupBy</code>, so the loop does the grouping
    and the totalling at once inside a mutable map — compact, but the four
    requirements (July only, per category, totalled, ranked) are tangled
    into one body. The FxDart chain keeps them as four visible steps:
    <code>filter</code> the month, <code>groupBy</code> category,
    <code>map</code> each group to its total, <code>sortBy</code> descending
    — and <code>join</code> formats the report. Adding a requirement
    (say, a minimum total) is one more chain step; in the loop it is
    another branch inside an already-busy body.
  </p>

  <h2>Two FxDart spellings</h2>
  <p>
    The benchmark below carries a <strong>third bar</strong>, which only one
    other page does. The chain above is the one to write: <code>filter</code>
    and <code>foldBy</code> as two named steps, each answering one question.
    What it cannot do is inline its own predicate. <code>filter</code> is a
    lazy stage, so it keeps that predicate in an iterator field, and the AOT
    compiler cannot see through a field — every transaction pays a real
    indirect call whose body never fuses into the loop. <code>foldBy</code>
    does not have that problem; it is strict, so its callbacks are parameters
    and get inlined.
  </p>
  <p>
    <a href="../tutorials/foldByOrSkip.html"><code>foldByOrSkip</code></a>,
    shown above <code>main</code> in the FxDart panel, moves the test into the
    key: a <code>null</code> key skips the row, so one callback both selects
    and buckets, and it is a parameter of a body small enough to inline. Over
    1,000,000 transactions that is the difference between the second and third
    bars; the first is the hand-written loop.
  </p>
  <p>
    Write the chain by default — two unrelated questions read better as two
    steps. Reach for <code>foldByOrSkip</code> when the pipeline is hot and a
    profile says that predicate is the cost.
  </p>
