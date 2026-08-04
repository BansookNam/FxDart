---
slug: duplicate-transactions
title: Detect duplicated transactions — Dart vs FxDart
description: Flag charges with the same merchant, amount, and day — putIfAbsent plus nested loops in plain Dart vs groupBy + filter + flatMap in FxDart.
heading: Detect duplicated transactions
order: 21
tier: 3
functions: groupBy, filter, flatMap, map, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A charge that appears twice with the same <strong>merchant, amount,
    and day</strong> is probably a double-swipe. Find every such group in
    July's transactions and list <em>each transaction involved</em> so
    the user can review them — but do not flag the same merchant and
    amount on <em>different</em> days (a repeat coffee is not a
    duplicate). The data is in the code below; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The algorithm is group–keep–flatten, and FxDart writes it as exactly
    those three words: <code>groupBy</code> the merchant|amount|day key,
    <code>filter</code> the groups with more than one member,
    <code>flatMap</code> the survivors back into individual transactions
    (<code>map</code> + <code>join</code> format them). Native Dart has
    none of the three as vocabulary: grouping becomes a
    <code>putIfAbsent</code> loop, keeping-and-flattening becomes nested
    <code>for</code> loops with an <code>if</code> between them. Both are
    correct; only one still looks like the sentence that specified it.
  </p>
