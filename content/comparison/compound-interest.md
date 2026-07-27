---
slug: compound-interest
title: Compound interest table — Dart vs FxDart
description: A year-by-year balance table at 5% — a mutating accumulator loop in plain Dart vs range + scan + map in FxDart.
heading: Compound interest table
order: 16
tier: 2
functions: range, scan, map
domain: general
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Print a year-by-year balance table for <strong>$1000 at 5%</strong>
    compound interest over six years — one line per year, starting from the
    year-0 opening balance, each amount formatted to two decimals. The
    constants are in the code below; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    A running balance is a <em>running fold</em>, and core Dart has no word
    for it: <code>fold</code> gives only the final value, so the native
    version falls back to a loop that seeds a list with the year-0 line,
    mutates <code>balance</code>, and appends — the compounding rule, the
    iteration, and the formatting all share one body. FxDart's
    <code>scan</code> turns each intermediate balance into a value in the
    pipeline: the seed is the year-0 row, the compounding rule is one pure
    function, and formatting is a separate <code>map</code> step. Want the
    year the balance first passes $1200? Chain a filter — the loop version
    has to grow another flag instead.
  </p>
