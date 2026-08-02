---
slug: live-latest-value
title: A live current value for late readers — RxDart vs FxDart
description: A dashboard that connects late still gets the current temperature instantly — BehaviorSubject replays the latest; pull caches it by hand.
heading: A live current value for late readers
order: 47
tier: 4
functions: fx, streams
domain: sensors
verdict: rxdart
async: true
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
    "The latest value, replayed to whoever shows up" is not a pipeline —
    it is a piece of <em>shared, multicast state</em>, and RxDart has a
    dedicated object for it. A <code>BehaviorSubject</code> is both the
    sink the sensor writes to and a stream every subscriber can read, and
    its one defining behavior is exactly this requirement: a late
    listener first receives the most recent value, then the live feed.
    The whole rx panel is "add updates, subscribe late, collect".
  </p>
  <p>
    FxDart deliberately omits anything like a subject — a pull pipeline
    is a single-consumer chain of demand, not a broadcast hub. The FxDart
    panel has to <em>simulate</em> the subject: a broadcast controller, a
    hand-written listener that caches the latest value into a variable,
    and an <code>fxStream</code> bridge for the remainder once the late
    reader joins. It prints the same lines, but every piece the subject
    gave for free (the cache, the replay-on-join, the second
    subscription's lifecycle) is now manual code that must be kept
    correct. The practical call: for multicast latest-value state, use
    RxDart — and bridge into a typed FxDart pipeline downstream of the
    subject when the per-value processing grows.
  </p>
