---
slug: category-rank
title: Rank the month by category — Dart vs FxDart
description: Group, total, and rank spending — groupListsBy plus a comparator swap in plain Dart vs one groupedBy → sortByDesc chain in FxDart.
heading: Rank the month by category
order: 51
tier: 4
functions: filter, groupedBy, map, sumBy, sortByDesc, take
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Given ledger transactions with a few June stragglers mixed in, keep
    only <strong>July 2026</strong> and rank the <strong>top three
    categories by total spend</strong> — biggest first — printing each
    category with its total and how many purchases it covers. The data is
    in the code below; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The task is one thought — keep the month, group, total, rank, top
    three — and the FxDart version is one chain: <code>filter</code> keeps
    July, <code>groupedBy</code> yields
    <code>(key:, items:)</code> records, so the per-category total is a
    <code>map</code> step away, and <code>sortByDesc</code> says
    "biggest first" by key. Native Dart splits the same thought across a
    <code>Map</code>: <code>groupListsBy</code> (from
    <code>package:collection</code>) ends the fluent chain, and descending
    order means the comparator-operand swap
    <code>(a,&nbsp;b)&nbsp;=&gt;&nbsp;b…compareTo(a…)</code> — a classic
    silent-bug site, and the reason the FxDart side never negates a key.
  </p>
  <p>
    Honestly: <code>package:collection</code> covers the grouping well, and
    for a one-off report the native version is fine. The chain earns its
    keep as the report grows — every added step (a filter, a second
    ranking) extends the pipeline instead of another <code>entries</code>
    round-trip.
  </p>
