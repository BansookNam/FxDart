---
slug: empty-report-default
title: A default line for an empty report — RxDart vs FxDart
description: Filter to a category with no matches and still print something — defaultIfEmpty on the stream vs ifEmpty on the pull chain, the same idea in both models.
heading: A default line for an empty report
order: 7
tier: 1
functions: fx, filter, ifEmpty, map
domain: transactions
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A spending report filters this month's transactions down to the
    <code>travel</code> category — and there aren't any. An empty report
    should not print nothing: it should print a single
    <em>no travel spending</em> line instead. The data is in the code;
    both versions must print the line shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Hardly at all — and in the same place. "Emptiness needs a fallback"
    is a problem both models
    hit in exactly the same place — a downstream stage cannot tell
    <em>filtered to nothing</em> from <em>never had anything</em> unless
    the pipeline says what to emit in that case — and both libraries
    answer with one operator. RxDart's <code>defaultIfEmpty</code> injects
    the default when the source completes without an event; FxDart's
    <code>defaultIfEmpty</code> (added in 0.7.2, openly borrowed from the
    Rx vocabulary, with <code>ifEmpty(() =&gt; fallback)</code> as the
    lazy whole-iterable form) yields it when the first pull finds
    nothing.
  </p>
  <p>
    The residual difference is the usual one in this Part: the stream
    version has to know it is empty by <em>waiting for completion</em>,
    so the whole program goes async over a fixed list, while the pull
    version discovers emptiness synchronously on the first demand. That
    cost is real but small here, and the operator parity is the story —
    a genuine tie, and a nice example of the two libraries trading ideas
    rather than competing.
  </p>
