---
slug: attempt
title: attempt — FxDart 101
description: FxDart attempt tutorial: move a Dart stream error onto the value channel as a typed Left, and put a Left back on the error channel with raiseLefts — with a live playground.
heading: <code>attempt</code> &amp; <code>raiseLefts</code>
section: 14
crumb: attempt
prev: onErrorResume.html
prevLabel: onErrorResume
next: mapEither.html
nextLabel: mapEither
---
  <p class="hero-sub">Move a failure between the two channels a Dart <code>Stream</code> has: the error channel every <code>listen(onError:)</code> sees, and the value channel carrying <code>Either</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The events layer's own error tools —
    <code><a href="onErrorResume.html">onErrorReturn</a></code>,
    <code>onErrorResume</code>,
    <code><a href="retryOn.html">retryOn</a></code>,
    <code>retryOnError</code> — all speak untyped
    <code>Object</code>, because that is what the error channel carries.
    <code>attempt</code> is the bridge to the typed half of the library:
    each data event becomes a <code>Right</code>, each error event a
    <code>Left</code> built by <code>onThrow</code>. Once the failure is a
    <code>Left</code>, the compiler knows its type and a
    <code>switch</code> over the event cannot forget to handle it.
  </p>
  <p>
    Convert at the source boundary and stay on the value channel
    afterwards. A Dart error is not terminal, so the source keeps its
    subscription and later events still arrive — the same reason
    <code>onErrorReturn</code> substitutes <em>per error</em> rather than
    rescuing once. The difference is the result type:
    <code>onErrorReturn</code> keeps <code>T</code> by picking a
    placeholder; <code>attempt</code> changes it to
    <code>Either&lt;E, T&gt;</code> so the failure is named.
  </p>
  <p>
    Place <code>attempt</code> <strong>after</strong>
    <code>retryOn</code> / <code>retryOnError</code> / <code>FxEvents.retry</code>,
    never before. Those operators watch the error channel, and there is
    nothing left there to retry once the error has become a value.
  </p>
  <p>
    <code>raiseLefts</code> is the other direction, on non-nullable
    failures only, because Dart cannot <code>throw</code> null. It
    unwraps each <code>Right</code> and puts each <code>Left</code> back
    on the error channel, for a boundary that hands the stream to
    <code>Stream</code>-based code expecting Dart errors. An
    <code>attempt</code> / <code>raiseLefts</code> round trip keeps the
    failure value and not its stack trace — <code>Left</code> does not
    carry one.
  </p>

  <h2>Demo 1 · Errors become Left, the chain keeps running</h2>
  {{playground:0}}

  <h2>Demo 2 · raiseLefts, the other direction</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: <code>attempt</code> after retry converts a retried
    failure; <code>attempt</code> before retry leaves nothing on the
    error channel to retry.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="onErrorResume.html"><code>onErrorReturn</code> / <code>onErrorResume</code></a> — recover on the error channel, untyped ·
    <a href="mapEither.html"><code>mapEither</code></a> — stay on the value channel; a raise becomes a <code>Left</code> ·
    <a href="either.html"><code>Either</code></a> — the sealed result type these operators wrap
  </div>
