---
slug: streams
title: Stream bridges — FxDart 101
description: FxDart Stream bridges: fromStream, fxStream, and toStream() — round-trip between Dart Streams and FxAsyncIterable, with a live playground.
heading: Stream bridges
section: 11
crumb: Stream bridges
next: concurrent.html
nextLabel: concurrent
---
  <p class="hero-sub">fromStream, fxStream, and .toStream() — cross freely between Dart's Stream and FxDart's FxAsyncIterable.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>fromStream</code> converts any <code>Stream</code> — single- or
    broadcast-subscription — into an <code>FxAsyncIterable</code>, so you can
    run the whole FxDart operator set (<code>map</code>, <code>filter</code>,
    <code>concurrent</code>, …) over data that's arriving from a socket, a
    file, a widget's event stream, or anywhere else Dart hands you a
    <code>Stream</code>. <code>fxStream(stream)</code> is the same thing, but
    returns a chainable <code>FxAsync</code> directly instead of a raw
    <code>FxAsyncIterable</code> — the async counterpart of <code>fx</code>
    and <code>fxAsync</code>.
  </p>
  <p>
    Going the other way, <code>.toStream()</code> drives an
    <code>FxAsyncIterable</code> (or <code>FxAsync</code> chain) to completion
    and re-emits its values as a plain <code>Stream</code> — handy when some
    other API (a <code>StreamBuilder</code>, for example) expects one. One
    caveat: <code>toStream()</code> always pulls <strong>sequentially</strong>,
    ignoring any <code>concurrent(n)</code> upstream of it — apply
    <code>concurrent</code>/<code>concurrentPool</code> to the chain
    <em>before</em> calling <code>.toStream()</code> if you need the
    parallelism to actually happen; the stream conversion itself won't add it.
  </p>

  <h2>Demo 1 · fromStream and fxStream</h2>
  <p>Both wrap a <code>Stream.fromIterable</code> so you can pipe an existing
    stream through FxDart operators:</p>
  {{playground:0}}

  <h2>Demo 2 · Round-trip, with a finite periodic stream</h2>
  <p>
    <code>Stream.periodic</code> never ends on its own, so
    <code>.take(n)</code> keeps the demo finite. The second half shows the
    reverse direction — building an <code>FxAsync</code> chain, then handing
    it back out as a plain <code>Stream</code> with <code>.toStream()</code>:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: keep only the values &gt;= 10 from this stream.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — lift a plain Iterable instead ·
    <a href="asyncVariants.html">async variants</a> — the *Async naming convention ·
    <a href="concurrent.html"><code>concurrent</code></a> — apply before toStream() for real parallelism ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — completion-order variant
  </div>
