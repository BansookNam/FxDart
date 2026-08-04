---
slug: price-drop-detection
title: Price drops between two snapshots — Dart vs FxDart
description: Compare two price-list snapshots and report what got cheaper — indexBy + filter + sortBy + head + sumBy vs a map literal and where/fold chains.
heading: Price drops between two snapshots
order: 53
tier: 4
functions: indexBy, filter, map, sortBy, head, sumBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Two snapshots of a shop's price list (data in the code): June and July.
    Some items got cheaper, some more expensive, one was discontinued and
    one is new. Report every item that <strong>dropped in price</strong> —
    old price, new price, and the drop — sorted by biggest drop first, plus
    a callout for the single biggest drop and the total savings. Both
    versions must print the report under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The whole task is one flow: index June by SKU, keep July items that got
    cheaper, pair each with its drop, sort by drop. FxDart has a named step
    for each move — <code>indexBy</code> for the lookup table,
    <code>filter</code> → <code>map</code> → <code>sortBy</code> for the
    pipeline, then <code>head</code> and <code>sumBy</code> reuse the same
    result list for the summary lines. Native Dart can express it — a map
    literal for the index, <code>where</code>/<code>map</code>/
    <code>sortedBy</code> for the chain — but the vocabulary is scattered:
    <code>fold</code> with a seed instead of <code>sumBy</code>,
    <code>sortedBy&lt;num&gt;</code> with a negated key, and no name at all
    for "build me a lookup by key".
  </p>
