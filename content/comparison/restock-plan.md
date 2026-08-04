---
slug: restock-plan
title: Inventory restock plan — Dart vs FxDart
description: Prioritize below-threshold items and cut the order list at a budget — scan + zip + takeWhile as data flow vs a mutable running total and break.
heading: Inventory restock plan
order: 32
tier: 4
functions: filter, sortBy, scan, drop, zip, takeWhile, map, sumBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    From a stock list (data in the code), find items <strong>below their
    minimum stock</strong>, prioritize by biggest deficit, and order them in
    that priority order — but stop before the <strong>cumulative cost
    exceeds the $500 budget</strong>. Print each planned order with its
    running total, then a summary of what was ordered and what is left.
    Both versions must print the plan under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The budget cutoff is the interesting part. FxDart turns the running
    total into <em>data</em>: <code>scan</code> produces the cumulative cost
    stream, <code>zip</code> pairs each item with its running total, and
    <code>takeWhile</code> cuts the plan at the budget — the cutoff rule is
    one predicate on one line, and the running totals are already there to
    print. Native Dart interleaves everything in a single loop: a mutable
    <code>running</code> variable, an early <code>break</code>, and
    formatting all share the loop body, so the policy ("stop when over
    budget") lives inside control flow instead of being a visible pipeline
    stage you could move or test on its own.
  </p>
