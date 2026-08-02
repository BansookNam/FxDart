---
slug: unique-visitors
title: Unique visitors, first visit kept — RxDart vs FxDart
description: Dedupe a visit log across the whole feed, keeping each user's first visit — distinctUnique with equals+hashCode vs uniqBy with one key function.
heading: Unique visitors, first visit kept
order: 5
tier: 1
functions: fx, uniqBy, map
domain: users
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    Today's visit log holds eight visits by four accounts. Keep each
    user's <strong>first</strong> visit only — deduping across the whole
    log, not just adjacent entries — and print who they are, when they
    first arrived, and the unique count. The data is in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    This is one of RxDart's best matches for an FxDart operator.
    Plain <code>Stream.distinct</code> only compares <em>adjacent</em>
    events (FxDart's <code>uniqAdjacent</code> is the same idea), so
    RxDart adds <code>distinctUnique</code>: dedup across the whole
    stream, first occurrence kept — exactly <code>uniqBy</code>'s
    contract. Both maintain a seen-set for the stream's lifetime, both
    preserve arrival order, and ana's 09:40 and 11:48 revisits vanish
    identically on both sides.
  </p>
  <p>
    The remaining difference is ergonomic, not semantic. "Same visitor"
    is one key function for <code>uniqBy</code> —
    <code>(v) =&gt; v.user</code> — while <code>distinctUnique</code>
    asks for a matched <code>equals</code> + <code>hashCode</code> pair,
    two closures that must agree with each other. That is a mild
    inconvenience, not a model gap, and the async main is the usual
    stream overhead on fixed data. Verdict: a tie — the global-dedup operator exists on
    both sides and behaves the same way.
  </p>
