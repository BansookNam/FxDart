---
slug: fxEventsCreate
title: fxEventsCreate — FxDart 101
description: FxDart fxEventsCreate tutorial: construct an event chain from a value, a future, a generator, or a create callback — with a live playground.
heading: constructors
section: 14
crumb: fxEventsCreate
prev: fxEvents.html
prevLabel: fxEvents
next: whenComplete.html
nextLabel: whenComplete
---
  <p class="hero-sub">Cold constructors for an event chain: a value, an empty close, a future, a generator, a create callback — no Stream you already had to wrap.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="fxEvents.html">fxEvents</a>(stream)</code> wraps a
    stream you already have. These constructors
    <strong>are</strong> the stream. They stay cold: wrapping or naming
    them listens to nothing; a terminal
    (<code>toList</code>, <code>head</code>, <code>listen</code>) is
    what starts events flowing. That is the same honesty rule the rest
    of the chain keeps.
  </p>
  <p>
    The simple ones first. <code>FxEvents.value(x)</code> emits
    <code>x</code> and closes — Rx's <code>of</code>/<code>just</code>.
    <code>FxEvents.empty()</code> closes with nothing.
    <code>FxEvents.never()</code> never emits and never closes;
    listening hangs until cancelled, so it is a mention, not a demo.
    <code>fromFuture</code> emits the future's value (or its error) and
    closes; the future is not observed until a listener arrives.
    <code>generate(initial, condition, iterate)</code> walks
    <code>initial, iterate(initial), …</code> while the condition
    holds — each step is a timer tick, so an infinite generator can
    still be cancelled.
  </p>
  <p>
    Time, then factories. <code>FxEvents.timer(delay)</code> emits
    <code>0</code> after the delay and closes; with
    <code>every</code> it continues <code>1, 2, …</code> on that
    period. <code>periodic</code> is the never-completing clock
    (tick count when the computation is omitted) — cancel it; do not
    <code>toList</code> it. <code>defer(factory)</code> builds a fresh
    inner stream on every listen — the factory, not the wrapper; the
    chain stays single-subscription. <code>using</code> acquires a
    resource on listen, mirrors it, and releases exactly once — the
    push counterpart of pull
    <code><a href="using.html">using</a></code>.
    <code>fromPattern(add, remove)</code> is the typical
    <code>on</code>/<code>off</code> bridge. And
    <code>create(init)</code> calls <code>init</code> with an
    <code>EventEmitter</code>: <code>add</code>, <code>addError</code>,
    <code>close</code>, and <code>onCancel</code> for teardown. A throw
    from <code>init</code> is forwarded and the stream closes.
  </p>
  <p>
    fxdart events layer, after Rx's <code>of</code>/<code>just</code>,
    <code>EMPTY</code>, <code>NEVER</code>, <code>from</code>,
    <code>interval</code>, <code>timer</code>, <code>defer</code>,
    <code>generate</code>, <code>fromEventPattern</code>,
    <code>using</code>, and the <code>Observable</code> constructor /
    <code>create</code>.
  </p>

  <h2>Demo 1 · value, empty, generate</h2>
  {{playground:0}}

  <h2>Demo 2 · defer, and fromFuture</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>create</code> that emits 1, 2, 3, then closes.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — wrapping a Stream you already have ·
    <a href="using.html"><code>using</code></a> — the pull-layer original: acquire on first pull, release once ·
    <a href="share.html"><code>share</code></a> — when one run of a chain needs many listeners
  </div>
