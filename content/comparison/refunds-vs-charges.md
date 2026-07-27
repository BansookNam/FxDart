---
slug: refunds-vs-charges
title: Refunds vs charges, both formatted — Dart vs FxDart
description: Split a ledger into refunds and charges and print both sides — two where passes in plain Dart vs one partition in FxDart.
heading: Refunds vs charges, both formatted
order: 15
tier: 2
functions: partition, map, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A ledger mixes charges and refunds (negative amounts). Split it into the
    two groups, format every transaction as
    <code>merchant $amount</code>, and print one line per group —
    refunds first. The data is in the code below; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Dart has no <code>partition</code> — when you need <em>both</em> halves,
    <code>where</code> only gives you one, so the native version filters
    twice: once with the predicate, once with its negation, written out by
    hand (<code>&lt; 0</code> and <code>&gt;= 0</code>). That is two passes
    over the data and two predicates to keep in sync — if the refund rule
    ever changes, nothing forces the second line to follow. FxDart's
    <code>partition</code> makes the split one declaration: a single
    predicate, a single pass, and a record destructure that names both
    halves. The <code>map</code> + <code>join</code> formatting afterwards
    is the same in both.
  </p>
