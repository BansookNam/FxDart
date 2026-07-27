---
slug: monthly-ledger-report
title: Full monthly ledger report — Dart vs FxDart
description: One report string from a ledger — total, category breakdown, top merchants — as three fxdart pipelines vs loops and intermediate maps.
heading: Full monthly ledger report
order: 31
tier: 4
functions: filter, sumBy, groupBy, map, sortBy, take, zipWithIndex, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    From one month of ledger transactions (data in the code), build a single
    report string with three sections: the <strong>total spent</strong>
    (income excluded), a <strong>per-category breakdown</strong> sorted by
    spend, and the <strong>top 3 merchants</strong> as a numbered list.
    Both versions must print exactly the report shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Each report section is the same shape in FxDart: <code>groupBy</code> →
    <code>sumBy</code> per group → <code>sortBy</code> descending — then
    <code>take</code> and <code>zipWithIndex</code> turn the merchant section
    into a numbered top-3 without an index variable. The native version has
    to say each of those steps in a different dialect: <code>fold</code> with
    a seed for every sum, <code>sortedBy&lt;num&gt;</code> with a negated
    key, a collection-for for one section and an indexed <code>for</code>
    loop for the other. The report grows section by section on both sides —
    but only one side grows by appending pipeline steps rather than
    accumulating differently-shaped intermediate variables.
  </p>
