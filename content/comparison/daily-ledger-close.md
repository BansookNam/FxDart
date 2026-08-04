---
slug: daily-ledger-close
title: Finale — DailyLedger monthly close — Dart vs FxDart
description: The finale: load ledger entries 3 at a time, then compute the July summary and category breakdown — the real DailyLedger app shapes, both ways.
heading: Finale — DailyLedger monthly close
order: 51
tier: 4
functions: toAsync, map, concurrent, filter, partition, sumBy, groupBy, sortBy, take
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Close the month for a personal ledger. Ten entries live in a store
    (fixed data in the code below); load each by id — at most
    <strong>three loads in flight</strong>, proven by the max-in-flight
    counter — then compute the July&nbsp;2026 close: keep only July entries
    (one straggler is from June), split income from spending, total each
    side, and print the net plus the top three spending categories with
    entry counts.
  </p>
  <p>
    The shapes here are lifted from a real app: the <code>Entry</code>
    model, the income/spending split (<code>filter</code> →
    <code>partition</code> → <code>sumBy</code> each half), and the
    category breakdown (<code>groupBy</code> → per-group <code>sumBy</code>
    → <code>sortBy</code> descending → <code>take(3)</code>) mirror
    DailyLedger's <code>monthSummary</code> and
    <code>categoryBreakdown</code> pipelines, with the async load phase
    (<code>toAsync</code> → <code>map</code> → <code>concurrent(3)</code>)
    in front.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Fifty examples in, this is the pattern they all add up to: plain Dart
    needs three dialects for one feature — <code>package:collection</code>
    helpers for grouping, <code>fold</code> with explicit seeds for the
    totals, and a hand-rolled worker pool the moment the load phase needs a
    concurrency bound. Each piece is fine; together they make the business
    logic the hardest thing on the screen to find. The FxDart version is
    the same vocabulary from the load phase to the report — and because
    every stage is a pure pipeline, each one can be lifted out and unit
    tested as <em>entries in, view data out</em>.
  </p>
  <p>
    These pipelines are not a demo confection: they are how
    <a href="{{root}}DailyLedger/">the DailyLedger demo app</a> actually
    computes its dashboard — same model, same operators, running live in
    your browser. If the fifty comparisons showed you the words, DailyLedger
    is the sentence they were building toward.
  </p>
