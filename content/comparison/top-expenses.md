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
    They barely do — this one is a tie on the page. Both sides sort on a
    negated key to get descending order and take the first three;
    <code>package:collection</code>'s <code>sortedBy</code> is every bit as
    direct as FxDart's <code>sortBy</code> (core <code>List.sort</code> alone
    would mutate in place and need an explicit comparator, but
    <code>collection</code> is a standard dependency). The only real
    difference in the listing is where the vocabulary lives: an extension
    method from a package vs a step in a chain that also offers
    <code>scan</code>, <code>chunk</code>, and async variants. Pick either
    with a clear conscience.
  </p>
  <p>
    The listing is a tie; the clock is not. At a million rows the bars
    below have FxDart about 2.6× faster (200 ms vs 521 ms), and that is
    not a smarter big-O — both copy the list and run a stable
    O(n log n) merge sort. The difference is what one comparison costs.
  </p>
  <p>
    Native <code>sortedBy</code> is collection's <code>mergeSortBy</code>:
    it sorts the <em>rows</em> and calls the key extractor
    <em>inside every comparison</em>. A million rows is about twenty
    million calls to <code>(t) => -t.amount</code>. The key type is a
    generic <code>K extends Comparable</code> — here <code>num</code> —
    so each of those keys is a heap-allocated boxed <code>double</code>
    compared through a virtual <code>compareTo</code>.
  </p>
  <p>
    FxDart's <code>sortBy</code> extracts first. One walk of the list
    writes every key into a <code>Float64List</code> (it noticed they
    were all <code>double</code>). Then it merges the keys and the rows
    <em>together</em>, sequentially: each comparison is two machine
    doubles from a typed array, using a VM compare on this data (the
    amounts are ordinary finite positives, so there is no NaN or
    <code>-0.0</code> to force the slower <code>compareTo</code> path).
    One extraction per row, no boxing, no dispatch, and no random index
    chase. An earlier <code>sortBy</code> did decorate by sorting a list
    of indices with <code>List.sort</code>; that is gone. The merge is
    stable by construction — equal keys keep their input order on both
    sides now.
  </p>
  <p>
    The honest limit: when the keys are not uniformly
    <code>double</code>, <code>int</code>, or <code>String</code>,
    <code>sortBy</code> falls back to a generic comparator and the
    advantage disappears. Memory at a million rows is close (about
    123 MB vs 130 MB) — both keep the row copy plus a scratch buffer.
    The amounts here are all distinct, so stability does not show on
    the printed three lines.
  </p>
