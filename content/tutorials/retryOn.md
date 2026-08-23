---
slug: retryOn
title: retryOn — FxDart 101
description: FxDart retryOn tutorial: resubscribe on error or on completion, with a retry budget, a delay, or a notifier — plus whenComplete teardown — with a live playground.
heading: <code>retryOn</code>, <code>repeat</code> &amp; <code>whenComplete</code>
section: 14
crumb: retryOn
prev: debounceOn.html
prevLabel: debounceOn
next: onErrorResume.html
nextLabel: onErrorResume
---
  <p class="hero-sub">Resubscribe on error or on completion — with a budget, a delay, or a notifier that decides when to try again.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The pull layer's <code><a href="retry.html">retry</a></code> rebuilds
    an iterable. On the push side the same idea is a
    <strong>resubscribe</strong>, and there are two shapes. One rebuilds
    the stream from a factory —
    <code><a href="onErrorResume.html">FxEvents.retry</a></code>, already
    covered — which is the right move for a one-shot
    <code>StreamController</code>. The other re-listens the same stream,
    and that is this page: <code>retryOnError</code>,
    <code>retryOn</code>, <code>repeat</code>, <code>repeatOn</code>.
  </p>
  <p>
    Re-listening needs a source that allows it.
    <code>Stream.multi</code>, <code>Stream.fromIterable</code>, and a
    broadcast all do; a spent single-subscription controller will error
    on the second listen. Reach for
    <code><a href="onErrorResume.html">FxEvents.retry</a></code> (or
    <code>FxEvents.defer</code>) when the source is one-shot.
  </p>
  <p>
    <code>retryOnError({count, delay})</code> resubscribes on error —
    forever when <code>count</code> is null, or up to that many
    <em>retries</em> (so <code>count: 2</code> is three attempts).
    <code>delay</code> if set is consulted with the 1-based retry number
    before each retry. When the budget is spent the last error is
    forwarded and the stream closes.
  </p>
  <p>
    <code>retryOn(notifier)</code> is Rx's <code>retryWhen</code>: the
    error is <strong>not</strong> forwarded; it is pushed into
    <code>notifier</code>, and a next on that stream resubscribes.
    Notifier complete completes the result without the error; notifier
    error is forwarded. <code>repeat</code> / <code>repeatOn</code> are
    the same pair on <strong>completion</strong> rather than error —
    errors forward and stop. <code>whenComplete</code> is Rx
    <code>finalize</code>: the callback runs exactly once on done, error,
    or cancel. fxdart events layer, after Rx's <code>retryWhen</code>,
    <code>retry</code>, <code>repeat</code>, <code>repeatWhen</code>, and
    <code>finalize</code>.
  </p>

  <h2>Demo 1 · retryOnError, with delay</h2>
  {{playground:0}}

  <h2>Demo 2 · Repeat a short stream twice</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: retryOn — the notifier decides when to resubscribe.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="onErrorResume.html"><code>FxEvents.retry</code></a> — the factory form, for sources you cannot re-listen ·
    <a href="retry.html"><code>retry</code></a> — the pull-layer original, with a backoff hook and per-element scope ·
    <a href="timeout.html"><code>timeout</code></a> — bound how long a pull may take, rather than how often it retries
  </div>
