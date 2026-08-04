---
slug: monthly-category-report
title: Monthly category report, sorted by spend — Dart vs FxDart
description: Filter a ledger to one month, total each category, and rank them — loop plus mutable map in plain Dart vs filter + groupBy + sortBy in FxDart.
heading: Monthly category report, sorted by spend
order: 29
tier: 3
functions: filter, groupBy, map, sortBy, join
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
