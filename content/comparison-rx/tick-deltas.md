---
slug: tick-deltas
title: Deltas between ticks — RxDart vs FxDart
description: Each price tick with its predecessor — pairwise in both libraries, list pairs on the stream side, typed records on the pull side.
heading: Deltas between ticks
order: 19
tier: 2
functions: fx, pairwise, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    From seven price ticks, print the six <strong>deltas</strong>: each
    tick next to its predecessor with the signed change to two decimal
    places (a flat tick prints <code>+0.00</code>). The data is in the
    code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They don't, by design: <code>pairwise</code> is one of the operators
    FxDart ported <em>from</em> Rx, because "each value with the one
    before it" is just as natural whether values are pushed or pulled.
    Both sides keep one value of state, emit nothing for the first tick,
    and produce n&nbsp;−&nbsp;1 pairs. The verdict is a tie and the
    interesting part is the small typing difference in what a "pair" is.
  </p>
  <p>
    RxDart's <code>pairwise</code> emits a two-element
    <code>List&lt;double&gt;</code> — <code>p.first</code> and
    <code>p.last</code> are honest but the length-2 invariant lives in
    documentation, not in the type. FxDart's emits a Dart record
    <code>(double, double)</code>: <code>p.$1</code> and <code>p.$2</code>
    are the only fields there are, and the compiler knows it. That is a
    language-era artifact more than a model difference — records did not
    exist when RxDart's API froze — but it is representative of the pull
    library's habit of pushing invariants into types. On the model
    itself: nothing to choose between them here.
  </p>
