---
slug: top-merchants
title: Top 5 merchants by total spend — Dart vs FxDart
description: Group a ledger by merchant and rank the totals — groupListsBy + sortedBy in plain Dart vs one groupedBy → sortByDesc → take chain in FxDart.
heading: Top 5 merchants by total spend
order: 11
tier: 2
functions: groupedBy, sortByDesc, take
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Given a month of ledger transactions — each with a date, merchant, and
    amount — find the <strong>five merchants you spent the most at</strong>:
    group by merchant, total each group, sort the totals descending, and
    print the top five. The data is in the code below; both versions must
    print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Core Dart has no grouping at all, so the native version pulls in
    <code>package:collection</code> — and grouping there <em>ends</em> the
    chain: <code>groupListsBy</code> hands back a <code>Map</code>, so ranking
    it means naming an intermediate variable, re-entering through
    <code>.entries</code>, and reading each group as an untyped
    <code>kv.key</code> / <code>kv.value</code> pair. Sorting adds two more
    workarounds: an explicit <code>&lt;num&gt;</code> type argument (inference
    fails because <code>double</code> is <code>Comparable&lt;num&gt;</code>,
    not <code>Comparable&lt;double&gt;</code>) and a <em>negated</em> key,
    since <code>sortedBy</code> only sorts ascending.
  </p>
  <p>
    In FxDart the four steps are four links of one chain, top to bottom in the
    order the requirement states them. <code>groupedBy</code> stays inside the
    pipeline — it yields <code>(key:, items:)</code> groups instead of a map,
    so nothing has to be unpacked and re-wrapped — and
    <code>sortByDesc</code> says &ldquo;descending&rdquo; in its name instead
    of encoding it as a minus sign. No intermediate variable, no type-argument
    ceremony, no sign trick: the code says group, rank, take five.
  </p>
