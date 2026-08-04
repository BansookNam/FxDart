---
slug: flaky-api-retry
title: Poll a flaky API until first success — Dart vs FxDart
description: Retry-until-ready as a lazy pipeline — range + toAsync + map + dropWhile + head vs an imperative polling loop with a break.
heading: Poll a flaky API until first success
order: 38
tier: 4
functions: range, toAsync, map, peek, dropWhile, head
domain: general
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    An export job's status endpoint is deterministically flaky: the first
    four polls answer <code>pending</code>, the fifth answers
    <code>ready</code>. Poll it up to ten times, keep a log of every poll,
    stop at the first success, and report which attempt won — plus how many
    polls were actually made. No randomness: the failure count is fixed in
    the code below, so both versions print the same thing every run.
  </p>
  <p>
    The FxDart version writes the retry as data: <code>range(1, 11)</code>
    is the poll schedule, <code>map</code> is the transport,
    <code>peek</code> records the log, and <code>dropWhile</code> +
    <code>head</code> is the success policy. Because the chain is lazy and
    pulled one value at a time, <code>head</code> stops the polling — only
    five requests are ever made.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Honestly: the native <code>for</code> loop with a <code>break</code> is
    short, and nobody would call it wrong. The difference is where the
    pieces live. In the loop, the attempt budget, the logging, and the
    success test are all tangled into control flow — change one and you
    re-read the whole body. In the pipeline each concern is its own named
    step, so swapping the policy (first success → third success, add a
    transform, widen the budget) means editing one line. And the laziness
    guarantee — no polls after the winner — is structural in FxDart, while
    in the loop it depends on the <code>break</code> being in the right
    place.
  </p>
