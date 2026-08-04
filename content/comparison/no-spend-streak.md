---
slug: no-spend-streak
title: Longest streak of no-spend days — Dart vs FxDart
description: Longest run of July days with no transaction — loop with streak/longest counters in plain Dart vs range + scan + max in FxDart.
heading: Longest streak of no-spend days
order: 22
tier: 3
functions: range, map, scan, max, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    From one month of ledger transactions, find the <strong>longest streak
    of consecutive July days with no spending at all</strong> (July 2026
    has 31 days). Print a calendar strip marking each no-spend day with
    <code>#</code>, then the streak length. The data is in the code below;
    both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    A streak is a running value, and that is <code>scan</code>'s exact
    job: fold's every intermediate state, kept. The pipeline reads as the
    definition — the days (<code>range</code>), <code>map</code>ped to
    spent-or-not, <code>scan</code>ned into a running streak that resets
    on a spend day, and <code>max</code> picks the peak. The native loop
    computes the same thing with two mutable counters and an
    <code>if</code> — you verify it by mentally replaying iterations,
    and the streak logic is fused to the strip-building beside it. In the
    FxDart version the strip (<code>map</code> + <code>join</code>) and
    the streak are two independent, separately readable pipelines over
    the same <code>range</code>.
  </p>
