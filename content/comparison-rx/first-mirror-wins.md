---
slug: first-mirror-wins
title: Race two mirrors — RxDart vs FxDart
description: Two mirrors race for one payload — Rx.race and FxEvents.race both cancel the losing fetch mid-flight, and both prove it with one completed fetch.
heading: Race two mirrors
order: 46
tier: 4
functions: fxEvents, race
domain: general
verdict: tie
async: true
noBenchmark: timing
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
    They no longer do. Racing is a push idea — subscribe to everything,
    keep whoever speaks first, <em>cancel</em> the rest — and since
    fxdart 0.7.3 <code>FxEvents.race</code> is exactly that, matching
    <code>Rx.race</code> move for move: both mirrors are genuinely in
    flight, and the moment the EU mirror emits at 60&nbsp;ms the US
    subscription is cancelled, its <code>onCancel</code> fires, and the
    pending timer dies. Both panels prove it the same way — the
    completed-fetch count is still 1 long after the loser's 180&nbsp;ms
    deadline. The work was stopped, not just ignored, on both sides.
  </p>
  <p>
    The old FxDart panel could only decline to <em>start</em> the backup
    fetch; the events layer absorbed the Rx approach instead: a thin
    wrapper chain over plain <code>Stream</code>s that collides with
    nothing, rxdart included. RxDart's operator catalog remains far
    larger — fxdart keeps the events core small and hands the winner's
    per-value processing to the typed pull side via <code>.pull()</code>.
    For "first responder wins, losers are cancelled", the two are now
    operator-for-operator equivalent: a tie.
  </p>
