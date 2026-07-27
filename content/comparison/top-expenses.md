---
slug: top-expenses
title: Top 3 largest expenses — Dart vs FxDart
description: Largest three transactions of the month — sortedBy + take from package:collection vs sortBy + take in FxDart.
heading: Top 3 largest expenses
order: 3
tier: 1
functions: sortBy, take
alsoLink: chunk, scan
domain: transactions
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    From a month of expenses, print the <strong>three largest</strong> —
    merchant and amount, biggest first. The data is in the code below; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They barely do — this one is a tie. Both sides sort on a negated key to
    get descending order and take the first three;
    <code>package:collection</code>'s <code>sortedBy</code> is every bit as
    direct as FxDart's <code>sortBy</code> (core <code>List.sort</code> alone
    would mutate in place and need an explicit comparator, but
    <code>collection</code> is a standard dependency). The only real
    difference is where the vocabulary lives: an extension method from a
    package vs a step in a chain that also offers <code>scan</code>,
    <code>chunk</code>, and async variants. Pick either with a clear
    conscience.
  </p>
