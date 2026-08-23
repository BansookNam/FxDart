---
slug: debounceOn
title: debounceOn — FxDart 101
description: FxDart debounceOn tutorial: selector-driven time — debounce, delay, and throttle whose quiet window is a stream per value, not a Duration — with a live playground.
heading: <code>debounceOn</code>, <code>delayOn</code> &amp; <code>throttleOn</code>
section: 14
crumb: debounceOn
prev: spaceBy.html
prevLabel: spaceBy
next: retryOn.html
nextLabel: retryOn
---
  <p class="hero-sub">Selector-driven time: each value names the stream that decides when it is due — debounce, delay, and throttle without a Duration.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The Duration forms already live on
    <code><a href="debounce.html">debounce</a></code>,
    <code><a href="throttle.html">throttle</a></code>, and
    <code><a href="spaceBy.html">delay</a></code> — a fixed clock, the
    same wait for every value. The <code>xOn</code> family hands that
    clock to a <strong>selector</strong>: each value produces a stream,
    and the first event on that stream is the moment the value is due.
    Wait for a blur instead of 300ms; debounce longer queries longer;
    release a held value when a button fires rather than when a timer
    does.
  </p>
  <p>
    <code>debounceOn(selector)</code> is trailing-edge debounce with that
    stream as the quiet window. A newer value <strong>aborts</strong> the
    previous inner and starts a fresh one; the inner's first next emits
    the pending value; an inner that completes without a next
    <strong>drops</strong> it. A value still pending when the source
    closes is flushed, matching Duration
    <code><a href="debounce.html">debounce</a></code>.
  </p>
  <p>
    <code>delayOn(selector)</code> holds <em>every</em> value until its
    own inner fires — nothing is aborted, so two in-flight values can
    pass each other if their selectors do, matching Rx's
    <code>delayWhen</code>. The close waits for outstanding inners;
    errors are forwarded immediately, since only data is worth holding.
  </p>
  <p>
    <code>throttleOn(selector)</code> emits at most one event per inner
    window: <code>leading</code> (on by default, like the stream form of
    throttle) keeps the first of the window;
    <code>trailing</code> keeps the newest seen when the inner fires, or
    when the source closes mid-window. fxdart events layer, after Rx's
    selector forms of <code>debounce</code>, <code>delayWhen</code>, and
    <code>throttle</code>.
  </p>

  <h2>Demo 1 · A burst, released when its selector fires</h2>
  {{playground:0}}

  <h2>Demo 2 · Held until a notifier says go</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: one scroll offset per inner window, leading edge.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="debounce.html"><code>debounce</code></a> — the Duration form, and the callback wrapper ·
    <a href="throttle.html"><code>throttle</code></a> — the Duration form, leading and trailing ·
    <a href="spaceBy.html"><code>delay</code></a> — shift a whole stream by a fixed clock
  </div>
