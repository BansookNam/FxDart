---
slug: running-balance
title: Running account balance — Dart vs FxDart
description: Balance after every transaction — a mutable accumulator loop in plain Dart vs scan + map in FxDart.
heading: Running account balance
order: 7
tier: 1
functions: scan, map
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    An account opens July with a <strong>$250.00</strong> balance and sees six
    signed transactions — salary in, rent and groceries out. Print one
    currency line per step: the opening balance first, then the balance
    <strong>after each transaction</strong>. The data is in the code below;
    both versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Core Dart has <code>fold</code>, which collapses the list to the
    <em>final</em> balance — but this task needs every intermediate one, and
    there is no <code>scan</code>. So the native version falls back to a
    mutable <code>balance</code> variable threaded through a loop, and the
    formatting is interleaved with the accumulation. FxDart's
    <code>scan</code> yields each accumulated state as a value (the seed
    first — which lands the opening-balance line for free), and
    <code>map</code> formats afterwards as a separate, swappable step.
    Running state as a pipeline stage instead of a mutation is exactly the
    vocabulary Dart is missing here.
  </p>
