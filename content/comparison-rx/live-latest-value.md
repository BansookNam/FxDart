---
slug: live-latest-value
title: A live current value for late readers — RxDart vs FxDart
description: A dashboard that connects late still gets the current temperature instantly — BehaviorSubject and LiveValue both replay the latest, then stream live.
heading: A live current value for late readers
order: 39
tier: 4
functions: liveValue, fxEvents
domain: sensors
verdict: tie
async: true
noBenchmark: timing
---
  <h2>Requirement</h2>
  <p>
    A temperature feed pushes updates on a fixed schedule. A dashboard
    connects only after the first three updates have already gone by — it
    must still show the <strong>current</strong> value immediately
    (19.1&nbsp;°C, the latest at join time), then every later update. The
    schedule is simulated in the code; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They don't. "The latest value, replayed to whoever shows up"
    is <em>shared, multicast state</em>, and fxdart has a dedicated
    object for it too: <code>LiveValue</code> is
    <code>BehaviorSubject</code> reduced to its defining behavior — a
    sink the sensor writes to, a readable <code>.value</code>, and a feed
    where a late subscriber first receives the most recent value, then
    the live updates. Both panels are "add updates, subscribe late,
    collect" — no hand-cached variable, no extra caching listener.
  </p>
  <p>
    This is fxdart's events layer absorbing the Rx approach for
    the push side: <code>LiveValue.live</code> hands back an
    <code>fxEvents</code> chain — a thin wrapper over a plain broadcast
    <code>Stream</code>, so it collides with nothing, rxdart included —
    and <code>.pull()</code> crosses into the typed pull pipeline when
    the per-value processing grows. RxDart's subject family and operator
    catalog remain far larger; for latest-value-then-live itself, the
    panels are equivalent: a tie.
  </p>
