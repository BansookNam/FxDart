---
slug: top-category-average
title: Category with highest average expense — Dart vs FxDart
description: Group expenses and find the priciest category per transaction — collection groupBy + maxBy nested calls in plain Dart vs one FxDart chain.
heading: Category with highest average expense
order: 18
tier: 2
functions: groupBy, map, maxBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Given a month of expenses — each with a date, category, and amount —
    find the category with the <strong>highest average amount per
    transaction</strong>, and print it with the average formatted to two
    decimals. The data is in the code below; both versions must print the
    line shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Core Dart has neither <code>groupBy</code> nor <code>maxBy</code>;
    <code>package:collection</code> supplies both — but as top-level
    functions, not chain steps. The native version therefore reads
    inside-out: <code>maxBy(</code>… wrapping a <code>map</code> over
    entries of a <code>groupBy(</code>… — three idioms (function call,
    method chain, function call) for one three-step thought. FxDart keeps
    the reading order equal to the data flow: <code>groupBy</code> the
    transactions, <code>map</code> each group to
    <code>(category, average)</code>, <code>maxBy</code> the average. Same
    algorithm, but the sentence runs left to right.
  </p>
