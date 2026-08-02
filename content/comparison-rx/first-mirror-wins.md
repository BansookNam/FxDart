---
slug: first-mirror-wins
title: Race two mirrors — RxDart vs FxDart
description: Two mirrors race for one payload — Rx.race cancels the losing fetch mid-flight; a pull pipeline can only decline to start it.
heading: Race two mirrors
order: 46
tier: 4
functions: fx, toAsync, head
domain: general
verdict: rxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    The same payload is available from two mirrors: the EU mirror answers
    in 60&nbsp;ms, the US mirror in 180&nbsp;ms. Fetch it as fast as
    possible and make sure the slow fetch does <strong>not</strong> run to
    completion — prove it by counting completed fetches well after the
    loser's deadline. The mirrors are simulated in the code as cancellable
    streams; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Racing is a push idea: subscribe to everything, keep whoever speaks
    first, <em>cancel</em> the rest. <code>Rx.race</code> is exactly that —
    both mirrors are genuinely in flight, and the moment the EU mirror
    emits at 60&nbsp;ms the US subscription is cancelled, its
    <code>onCancel</code> fires, and the pending timer dies. That is why
    the completed-fetch count is still 1 long after the loser's
    180&nbsp;ms deadline: the work was stopped, not just ignored.
  </p>
  <p>
    The FxDart side prints the same lines but is <strong>not a
    race</strong>. <code>head</code> demands one item, so the pull chain
    listens to the first mirror only — the backup is never subscribed and
    never starts. Demand-driven laziness can decline to <em>start</em>
    work, but a pull pipeline has no way to cancel a <code>Future</code>
    already in flight: had we started both fetches, the loser would have
    run to completion and merely been ignored. And if the slow mirror had
    been listed first, this chain would simply have waited 180&nbsp;ms,
    while <code>Rx.race</code> would still have won with the backup. When
    the requirement is "first responder wins, losers are cancelled", use
    the stream model — this is RxDart's turf.
  </p>
