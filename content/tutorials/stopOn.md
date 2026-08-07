---
slug: stopOn
title: stopOn — FxDart 101
description: FxDart stopOn tutorial: end an event chain when another stream fires, and startOn to open it — cancellation gates for live feeds — with a live playground.
heading: <code>stopOn</code> &amp; <code>startOn</code>
section: 14
crumb: stopOn
prev: waitAll.html
prevLabel: waitAll
next: chunkOn.html
nextLabel: chunkOn
---
  <p class="hero-sub">Two gates driven by a second stream: <code>stopOn</code> closes the chain when the trigger fires, <code>startOn</code> opens it.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A push chain has no natural end. A pull pipeline stops when the
    consumer stops asking, but a live feed — a socket, a sensor, a
    <code>Stream.periodic</code> — keeps producing until something
    <em>cancels</em> it. Forgetting to do that is the classic leak:
    a screen is disposed, the widget is gone, and its subscription is
    still awake, still allocating, still calling <code>setState</code> on
    a corpse.
  </p>
  <p>
    <code>stopOn(trigger)</code> makes the shutdown part of the chain
    rather than a variable you have to remember to cancel. The first
    event on <code>trigger</code> closes the output and cancels
    <strong>both</strong> subscriptions — the source's and the trigger's.
    Nothing the trigger carries is read, only that it fired, so its type
    is <code>Stream&lt;void&gt;</code> and any stream at all will do.
  </p>
  <p>
    <code>startOn(trigger)</code> is the mirror: source events are
    <strong>dropped</strong> until the trigger fires once, and passed for
    good afterwards. It is the "wait until ready" gate — do not act on
    taps until the session has loaded. Note that it is unrelated to
    <code><a href="fxEvents.html">startWith</a></code>, which prepends a
    value rather than gating the start; the two names sit close together
    and mean quite different things.
  </p>
  <p>
    The <code>…On</code> suffix is the events layer's convention for
    "driven by a trigger stream", shared with
    <code><a href="sampleOn.html">sampleOn</a></code> and
    <code><a href="chunkOn.html">chunkOn</a></code>. fxdart events layer,
    after Rx's <code>takeUntil</code> and <code>skipUntil</code> — the
    names differ because <code>Fx.takeUntil</code> already means the
    predicate-driven <code>takeUntilInclusive</code> on the pull side,
    and one name cannot mean two things in one library.
  </p>

  <h2>Demo 1 · The off switch</h2>
  {{playground:0}}

  <h2>Demo 2 · The on switch</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: a session window, built from both gates.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fxSubscriptions.html"><code>FxSubscriptions</code></a> — the other half of teardown: cancel many subscriptions at once ·
    <a href="sampleOn.html"><code>sampleOn</code></a> — the same trigger convention, for reading instead of stopping ·
    <a href="race.html"><code>race</code></a> — cancellation decided by whoever speaks first
  </div>
