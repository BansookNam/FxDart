---
slug: invoice-summary
title: Line items to invoice summary — Dart vs FxDart
description: Turn order line items into per-category totals plus a grand total — two loop-and-fold idioms in plain Dart vs groupBy + sumBy + sortBy in FxDart.
heading: Line items to invoice summary
order: 27
tier: 3
functions: map, groupBy, sumBy, sortBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    An order's line items each have a product, category, quantity, and
    unit price. Print the invoice summary: one line per category with its
    total (quantity × unit price, summed), <strong>largest category
    first</strong>, then a grand total. The data is in the code below;
    both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The same amount, <code>qty * unitPrice</code>, is summed twice — per
    category and overall — and the two versions treat that differently.
    Native Dart spells it as two unrelated idioms: a mutating
    <code>for</code> loop into a map for the categories, then a
    <code>fold</code> with an explicit seed for the grand total. FxDart
    says "sum of a field" the same way both times — <code>sumBy</code> —
    once per <code>groupBy</code> group and once over all items, with
    <code>sortBy</code> ranking the rows. When the invoice grows a
    discount rule, one vocabulary changes in one place per pipeline; the
    native version changes a loop body <em>and</em> a fold.
  </p>
