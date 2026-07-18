---
slug: debounce
title: debounce — FxDart 101
description: FxDart debounce tutorial: delay a function call until things go quiet, with leading edge and cancel(), plus a live playground.
heading: <code>debounce</code>
section: 12
crumb: debounce
next: throttle.html
nextLabel: throttle
---
  <p class="hero-sub">Delays a function call until wait has passed since the last call — only the trailing call in a burst survives.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>debounce</code> wraps a callback so that repeated calls in quick
    succession collapse into a single call. Every call restarts a timer of
    length <code>wait</code>; the wrapped <code>func</code> only actually
    fires once <code>wait</code> has passed <em>without</em> another call —
    and it fires with whatever argument was passed in that last call. This is
    the classic "wait for the user to stop typing before searching" pattern.
  </p>
  <p>
    In JS, FxTS attaches a <code>.cancel()</code> method directly onto the
    returned function. Dart functions can't carry extra members, so FxDart
    returns a <code>Debounced&lt;T&gt;</code> instead — a class with a
    <code>call(T arg)</code> method, which Dart lets you invoke with plain
    function-call syntax (<code>debounced(arg)</code>) thanks to the
    <code>call()</code> convention, plus an explicit <code>.cancel()</code> to
    drop any pending invocation.
  </p>
  <p>
    By default (<code>leading: false</code>), only the <strong>trailing</strong>
    edge fires — the last call in a burst, after things go quiet. Pass
    <code>leading: true</code> and the <strong>first</strong> call in a burst
    fires immediately instead, with every call before the next quiet period
    suppressed.
  </p>

  <h2>Demo 1 · Trailing edge (the default)</h2>
  <p>Three rapid calls collapse into one — only the last argument survives:</p>
  {{playground:0}}

  <h2>Demo 2 · Leading edge and cancel()</h2>
  <p>
    <code>leading: true</code> fires immediately and suppresses the rest of
    the burst; <code>.cancel()</code> drops a pending trailing call entirely:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: wrap <code>save</code> in <code>debounce</code> (100ms wait)
    so only the final value survives the burst of calls below.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="throttle.html"><code>throttle</code></a> — fires on a schedule instead of after quiet ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — building timing demos ·
    <a href="concurrent.html"><code>concurrent</code></a> — rate-limiting for async pipelines ·
    <a href="shuffle.html"><code>shuffle</code></a> — seeded randomness
  </div>
