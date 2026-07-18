---
slug: throttle
title: throttle — FxDart 101
description: FxDart throttle tutorial: invoke a function at most once per wait period, with leading/trailing edges and cancel(), plus a live playground.
heading: <code>throttle</code>
section: 12
crumb: throttle
next: shuffle.html
nextLabel: shuffle
---
  <p class="hero-sub">Invokes a function at most once per wait period — on a schedule, unlike debounce's "wait for quiet."</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>throttle</code> guarantees <code>func</code> runs at most once every
    <code>wait</code>, no matter how often the throttled function is called.
    That's the key difference from <a href="debounce.html"><code>debounce</code></a>:
    debounce keeps <em>resetting</em> its timer on every call, so a
    continuous stream of calls can delay execution indefinitely; throttle's
    window is fixed once it starts, so calls still get through on a regular
    cadence — useful for things like scroll or resize handlers where you want
    periodic updates, not just one at the very end.
  </p>
  <p>
    Both <code>leading</code> and <code>trailing</code> default to
    <code>true</code>: the first call in a window fires immediately (leading
    edge), and if more calls arrive before the window closes, the
    <em>last</em> of those fires once the window ends (trailing edge, with
    the latest argument). Turn either off to get leading-only or
    trailing-only behavior. Like <code>debounce</code>, the returned
    <code>Throttled&lt;T&gt;</code> is a callable class with a
    <code>.cancel()</code> to drop a pending trailing call.
  </p>

  <h2>Demo 1 · Leading + trailing (the default)</h2>
  <p>The first call fires immediately; the last call in the window fires
    again once the window closes:</p>
  {{playground:0}}

  <h2>Demo 2 · Tuning leading/trailing, and cancel()</h2>
  <p>
    Turn off <code>leading</code> for trailing-only behavior, off
    <code>trailing</code> for leading-only, or call <code>.cancel()</code> to
    drop a pending trailing call:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: wrap <code>onClick</code> in <code>throttle</code> (100ms
    wait) so rapid clicks register at most twice — leading and trailing —
    instead of three separate times.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="debounce.html"><code>debounce</code></a> — waits for quiet instead of a fixed schedule ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — building timing demos ·
    <a href="shuffle.html"><code>shuffle</code></a> — seeded randomness ·
    <a href="concurrent.html"><code>concurrent</code></a> — rate-limiting for async pipelines
  </div>
