---
slug: expand-order-lines
title: Flatten orders into lines — RxDart vs FxDart
description: Flatten four orders into their ten order/sku line items — Stream.expand and fxdart flatMap are the same word for one-to-many, in source order.
heading: Flatten orders into lines
order: 3
tier: 1
functions: fx, flatMap, map
domain: orders
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    Yesterday's four orders each hold two or three line items. Flatten
    them into one list of <code>order/sku</code> lines — every item under
    its order id, in source order — and print the line count. The data is
    in the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    One-to-many flattening is bedrock in both models, and for a
    synchronous payload the two spellings are the same word:
    <code>Stream.expand</code> and FxDart's <code>flatMap</code> both
    take <em>element to iterable</em>, splice the pieces in source
    order, and hand the result to a formatting <code>map</code>. The
    panels are line-for-line parallel.
  </p>
  <p>
    The interesting divergence is just offstage. When each order's lines
    arrived <em>asynchronously</em>, the Rx side would graduate to
    RxDart's <code>flatMapIterable</code> or <code>flatMap</code> —
    inner <em>streams</em>, where merge order becomes a real question
    (interleaving by completion unless you concatenate). FxDart's
    async <code>flatMap</code> on a pulled pipeline stays in source
    order by construction. But that is a tier-4 story; on this in-memory
    job both sides express the flatten directly — the Rx panel doesn't
    even need an RxDart operator, core <code>Stream</code> carries it —
    and the only trace is the async main. A tie.
  </p>
