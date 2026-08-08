---
slug: top-expenses
title: Top 3 largest expenses — Dart vs FxDart
description: Largest three transactions of the month — sortedBy + take from package:collection vs sortBy + take in FxDart.
heading: Top 3 largest expenses
order: 1
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
  <p>
    The code is a tie; the clock is not. The Benchmark bars below have FxDart
    running 1.5–1.8× faster on the same data, and that is not a smarter
    algorithm — both sides run an O(n log n) comparison sort. The difference
    is what a single comparison costs. <code>sortedBy</code> sorts the
    elements and calls the key extractor <em>inside</em> every comparison: at
    a million rows it invokes <code>(t) => -t.amount</code> 19.6 million times
    against FxDart's 1 million, and because its key type is a generic
    parameter, each of those keys is a heap-allocated boxed
    <code>double</code> reached through a virtual <code>compareTo</code>.
    FxDart decorates instead — extract each key once, notice that every key
    came out <code>double</code>, copy them into a <code>Float64List</code>,
    sort a list of indices, then read the permutation back. From there each
    comparison is two machine doubles out of a typed array: no allocation, no
    dispatch.
  </p>
  <p>
    Of those two savings, the unboxing is the one that pays. Timed on the
    benchmark machine at a million rows, AOT-compiled: the same
    decorate-sort-undecorate holding <em>boxed</em> keys takes 1051 ms — worse
    than <code>sortedBy</code>'s 522 ms, since every comparison still
    dereferences two heap objects and dispatches a virtual
    <code>compareTo</code>, now with the extra random access an index
    permutation adds — and changing nothing but the key array to a
    <code>Float64List</code> drops it to 337 ms. Extracting the key once is
    nearly free on its own; keeping the keys unboxed is the whole win. That is
    also the honest limit of it: when the keys are not uniformly
    <code>double</code>, <code>int</code>, or <code>String</code>,
    <code>sortBy</code> falls back to the generic comparator and the advantage
    disappears.
  </p>
  <p>
    And the speed is bought, not free. Decorating keeps four arrays alive at
    the peak — copied items, keys, index permutation, result — where merge
    sort needs the copy plus a half-size scratch buffer, which is why the
    memory bar runs the other way (183 MB vs 126 MB at a million rows). The
    other cost is stability: <code>sortedBy</code> is a stable merge sort,
    while FxDart hands its indices to <code>List.sort</code>, which is not —
    rows with equal keys keep their input order on the native side and may
    come out shuffled on the FxDart side. Here the amounts are distinct and
    only three rows print, so none of it shows; on a leaderboard with ties it
    would.
  </p>
