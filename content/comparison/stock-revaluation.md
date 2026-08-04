---
slug: stock-revaluation
title: Revalue the stock, three lookups at a time — Dart vs FxDart
description: Live price lookups with a fallback — a worker pool plus hand-built pairs in plain Dart vs attach + concurrent + countWhere in FxDart.
heading: Revalue the stock, three lookups at a time
order: 48
tier: 4
functions: toAsync, attach, concurrent, map, sumBy, countWhere
domain: orders
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    A warehouse holds stock items, each with a SKU, an on-hand quantity,
    and a book price. Refresh every unit price from a price service —
    <strong>at most three lookups in flight</strong> — falling back to the
    book price for SKUs the service doesn't know. Print the revalued stock
    total and how many items used the fallback. The service is simulated
    in the code below with a fixed delay; both versions must print the
    lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Two hard parts stack here. The lookup must not lose its item —
    <code>attach</code> keeps each stock line beside the price the service
    returned (or <code>null</code>), which is what makes the fallback
    <code>r.$2&nbsp;??&nbsp;r.$1.bookPrice</code> a one-liner. And the
    fan-out must be bounded — <code>concurrent(3)</code> is the limit as an
    operator, since <code>attach</code> rides the same parallel-safe
    machinery as <code>map</code>. The tallies fall out of the vocabulary:
    <code>sumBy</code> for the total, <code>countWhere</code> for the
    fallback count.
  </p>
  <p>
    The native version has to build all of it: a shared-cursor worker pool
    for the limit, hand-made <code>(item, price)</code> records so the
    input survives the async hop, pre-sized result slots to keep order,
    and a <code>where(…).length</code> pass for the count. None of it is
    hard — all of it is ceremony that buries the four-step task.
  </p>
