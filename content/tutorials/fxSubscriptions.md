---
slug: fxSubscriptions
title: FxSubscriptions — FxDart 101
description: FxDart FxSubscriptions tutorial: hold many stream subscriptions in one bag and cancel, pause or resume them together — the dispose one-liner — with a live playground.
heading: <code>FxSubscriptions</code>
section: 14
crumb: FxSubscriptions
prev: liveValue.html
prevLabel: LiveValue
---
  <p class="hero-sub">A bag of subscriptions, cancelled together — so teardown is one call instead of one field per stream.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    An object that listens to several streams has to keep every
    subscription alive for one reason only: to cancel it again later. The
    result is the familiar pile of nullable fields, each declared at the
    top, each assigned in <code>initState</code>, each cancelled in
    <code>dispose</code> — and the leak is always the one somebody forgot
    to add to the third list.
  </p>
  <p>
    <code>FxSubscriptions</code> collapses that to one object.
    <code>add</code> puts a subscription in the bag and
    <strong>returns it</strong>, so it reads as an expression rather than
    a statement, and <code>cancelAll()</code> ends every one of them.
    Teardown becomes a single line: <code>Future&lt;void&gt; dispose() =&gt;
    subs.cancelAll();</code>
  </p>
  <p>
    <code>pauseAll()</code> and <code>resumeAll()</code> are the softer
    version, for when the work should stop without the wiring coming
    apart — a screen going to the background, a tab losing focus. Paused
    subscriptions buffer rather than drop, so nothing is lost across the
    gap.
  </p>
  <p>
    The bag is emptied <em>before</em> its cancellations are awaited, so a
    second <code>cancelAll()</code> during the wait cannot cancel anything
    twice, and the same object can hold a fresh generation of
    subscriptions afterwards. fxdart events layer, after Rx's
    <code>CompositeSubscription</code>.
  </p>
  <p>
    It pairs naturally with
    <code><a href="stopOn.html">stopOn</a></code>: use
    <code>stopOn</code> when a chain should end because something
    <em>happened</em>, and <code>FxSubscriptions</code> when a set of
    chains should end because the thing that owned them is
    <em>going away</em>.
  </p>

  <h2>Demo 1 · The dispose one-liner</h2>
  {{playground:0}}

  <h2>Demo 2 · Pausing without tearing down</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>addAll</code>, and reusing the bag after a cancel.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="stopOn.html"><code>stopOn</code></a> — teardown driven by an event rather than by an owner's lifecycle ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — the chain whose <code>listen</code> hands you the subscriptions this holds ·
    <a href="liveValue.html"><code>LiveValue</code></a> — has its own <code>close()</code>, and is not held by this bag
  </div>
