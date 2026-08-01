---
slug: using
title: using — FxDart 101
description: FxDart using and usingAsync tutorial: scope a resource to one lazy iteration — acquire on first pull, release exactly once — with a live playground.
heading: <code>using</code>
section: 11
crumb: using
prev: timeout.html
prevLabel: timeout
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Scopes a resource to one iteration: acquired on the first pull, released exactly once — on completion <em>or</em> on error.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Files, sockets, database cursors — the value they produce is a
    sequence, but their <em>lifetime</em> is a bracket:
    open, read, close, <em>even when reading throws</em>. Writing that
    bracket around a lazy pipeline is awkward, because "when the
    iteration ends" is wherever the consumer happens to be.
    <code>using(acquire, use, release)</code> ties the bracket to the
    iteration itself: <code>acquire</code> runs on the first pull (not
    when the pipeline is built — laziness is preserved),
    <code>use(resource)</code> supplies the elements, and
    <code>release(resource)</code> runs exactly once, after the last
    element or right before an error propagates.
  </p>
  <p>
    The async form <code>usingAsync</code> lets all three steps be
    asynchronous and composes with
    <code><a href="concurrent.html">concurrent</a></code> — release still
    fires exactly once even with overlapping pulls in flight. If
    <code>acquire</code> itself fails there is nothing to release, and
    the error simply propagates.
  </p>
  <p>
    One honest caveat, straight from the pull model: a consumer that
    <em>abandons</em> the iteration — <code>break</code> inside a
    <code>for-in</code>, dropping the iterator — never reaches the end,
    so <code>release</code> cannot run. Bound the iteration with
    <code><a href="take.html">take</a></code> (a bounded pipeline
    completes, and completion releases) or manage the resource with
    <code>try</code>/<code>finally</code> when early exit is the plan.
    fxdart extension (no FxTS counterpart), after Rx's <code>using</code>.
  </p>

  <h2>Demo 1 · The bracket around a lazy read</h2>
  {{playground:0}}

  <h2>Demo 2 · Release on error, exactly once</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: give the connection a lifetime.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="take.html"><code>take</code></a> — bound the iteration so completion (and release) is guaranteed ·
    <a href="peek.html"><code>peek</code></a> — observing values without owning a lifetime ·
    <a href="retry.html"><code>retry</code></a> — a fresh acquire per attempt when wrapped in a factory
  </div>
