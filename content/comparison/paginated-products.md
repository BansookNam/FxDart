---
slug: paginated-products
title: Paginated product listing — Dart vs FxDart
description: Filter, sort by price, and slice out page 2 — Dart already has skip/take, so this one is a genuine tie.
heading: Paginated product listing
order: 22
tier: 3
functions: filter, sortBy, drop, take, map
domain: orders
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A small shop catalog: name, price, in-stock flag. Show
    <strong>page 2</strong> of the in-stock products, sorted by price
    ascending, three per page — one line per product. The data is in the
    code below; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They barely do — this is a tie, and it is worth saying plainly.
    Pagination is exactly the shape Dart's <code>Iterable</code> already
    covers: <code>skip</code> and <code>take</code> read just as well as
    FxDart's <code>drop</code> and <code>take</code>, and both stay lazy.
    The only native wrinkle is sorting by a key — core Dart needs a
    comparator (<code>package:collection</code>'s <code>sortedBy</code>
    closes even that). Pick FxDart here only if the rest of the codebase
    already speaks its vocabulary; plain Dart loses nothing on this task.
  </p>
