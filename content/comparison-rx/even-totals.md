---
slug: even-totals
title: Total the valid even amounts — RxDart vs FxDart
description: Drop failed parses, keep evens, sum — a Stream pipeline with an async main vs one synchronous pull chain over the same fixed list.
heading: Total the valid even amounts
order: 4
tier: 1
functions: fx, compact, filter, sum
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A statement import produced a list of parsed amounts where two lines
    failed to parse (<code>null</code>). Drop the failures, keep the
    <strong>even</strong> amounts, and print their total. The data is in
    the code; both versions must print the line shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The pipelines are almost word-for-word the same —
    <code>whereNotNull → where → fold</code> against
    <code>compact → filter → sum</code>. What differs is everything
    <em>around</em> them. The RxDart side must lift a plain list into a
    <code>Stream</code>, go async, and <code>await</code> a fold, because
    a stream only yields values over turns of the event loop — even when
    every value is already sitting in memory. The FxDart side stays a
    synchronous expression: pull values, sum, done.
  </p>
  <p>
    That is the recurring theme of this Part: for data that is
    <em>finite and already here</em>, a stream adds a delivery mechanism
    the problem never asked for. RxDart's operator vocabulary is good —
    <code>whereNotNull</code> is exactly <code>compact</code> — but the
    model underneath charges an async tax on every fixed-data task. Here
    the entire answer is one number, so the ceremony — the lift, the
    async main, the awaited fold — is the whole difference between the
    two programs; that is what carries the verdict on this page, where
    later pairs with the same residue settle for a tie. The verdict
    flips in Part 4, where values genuinely arrive over time and that
    same machinery becomes the point.
  </p>
