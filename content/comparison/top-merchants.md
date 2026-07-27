---
slug: top-merchants
title: Top 5 merchants by total spend — Dart vs FxDart
description: Group a ledger by merchant and rank the totals — groupListsBy + sortedBy in plain Dart vs a groupBy → sortBy → take chain in FxDart.
heading: Top 5 merchants by total spend
order: 11
tier: 2
functions: groupBy, sortBy, take
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
    Core Dart has no <code>groupBy</code> at all — the native version has to
    pull in <code>package:collection</code> for <code>groupListsBy</code>,
    then switch idioms mid-task: an extension method to group, another
    (<code>sortedBy</code>, with an explicit <code>&lt;num&gt;</code> type
    argument and a negated key to get descending order) to rank. FxDart keeps
    the whole task in one vocabulary: <code>groupBy</code> produces the map,
    and <code>fx(map.entries)</code> continues the chain with
    <code>sortBy</code> and <code>take</code>. Same shape of solution — but
    one library, one pipeline, no type-argument ceremony.
  </p>
