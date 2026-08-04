---
slug: average-basket
title: Average order value over $100 — Dart vs FxDart
description: Mean total of large orders — where/map/average with package:collection vs filter + averageBy in FxDart.
heading: Average order value over $100
order: 4
tier: 1
functions: filter, averageBy
domain: orders
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    From a batch of shop orders, take only those totalling <strong>over
    $100</strong> and print their <strong>average value</strong> as a
    currency amount. The data is in the code below; both versions must print
    the line shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Honestly: they don't, much — a tie. Core Dart alone would need a
    fold-and-count (or a sum divided by a length, walking the data twice),
    but <code>package:collection</code>'s <code>.average</code> closes that
    gap, leaving <code>where → map → average</code> against
    <code>filter → averageBy</code>. FxDart saves the intermediate
    <code>map</code> by taking the key function directly, and
    <code>averageBy</code> is one word instead of an extension property on a
    projected iterable — vocabulary, not victory. Both read fine.
  </p>
