---
slug: streams
title: Stream bridges — FxDart 101
description: FxDart Stream bridges: fromStream, fromStreamLatest, fromStreamChunked, fromStreamNext, fxStream, and toStream() — four ways to pull a Dart Stream into FxAsyncIterable, with a live playground.
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
  <p>
    Crossing from push to pull is not one operation — it is four, because a
    stream may keep emitting while the consumer is busy. RxJS 9 names the
    four <code>iterateEach</code>, <code>iterateLatest</code>,
    <code>iterateBuffered</code> and <code>iterateNext</code>. FxDart maps
    them onto <code>fromStream*</code> (raw iterable) and
    <code>FxEvents.pull*</code> (chain):
  </p>
  <table>
    <thead><tr><th>RxJS 9</th><th>FxDart</th><th>while you are busy</th></tr></thead>
    <tbody>
      <tr><td><code>iterateEach</code></td><td><code>fromStream</code> / <code>.pull()</code></td><td>lossless FIFO — pause the source, queue every value</td></tr>
      <tr><td><code>iterateLatest</code></td><td><code>fromStreamLatest</code> / <code>.pullLatest()</code></td><td>drop superseded — keep only the newest unread value</td></tr>
      <tr><td><code>iterateBuffered</code></td><td><code>fromStreamChunked</code> / <code>.pullChunked()</code></td><td>batch — yield the arrivals as one list</td></tr>
      <tr><td><code>iterateNext</code></td><td><code>fromStreamNext</code> / <code>.pullNext()</code></td><td>demand-gated drop — ignore anything that arrived with no pull waiting</td></tr>
    </tbody>
  </table>
  <p>
    <code>fromStream</code> is the default and the one Demo 1 uses, because
    a file or a socket should not lose bytes. Reach for latest when a UI
    only cares about the current reading, chunked when the consumer wants
    work in batches, and next when stale events are worse than gaps.
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

  <h2>Demo 3 · Four ways to pull a stream</h2>
  <p>
    A sync burst of 1, 2, 3 arrives while a pull is already waiting.
    <code>fromStream</code> keeps every value;
    <code>fromStreamLatest</code> keeps only the newest;
    <code>fromStreamChunked</code> yields them as one list;
    <code>fromStreamNext</code> keeps only the value that met the waiting
    pull. The events-chain spellings are <code>.pull()</code>,
    <code>.pullLatest()</code>, <code>.pullChunked()</code>,
    <code>.pullNext()</code>.
  </p>
  {{playground:3}}

  <h2>Two chains, one Stream</h2>
  <p>
    A <code>Stream</code> is the one source that belongs to both halves of
    FxDart, so it carries two getters. They are not variants of each other —
    they are <strong>different models</strong>:
  </p>
  <table>
    <thead><tr><th></th><th><code>stream.fx</code></th><th><code>stream.fxEvents</code></th></tr></thead>
    <tbody>
      <tr><td>gives</td><td><code>FxAsync&lt;T&gt;</code></td><td><code>FxEvents&lt;T&gt;</code></td></tr>
      <tr><td>same as</td><td><code>fxStream(stream)</code></td><td><code>fxEvents(stream)</code></td></tr>
      <tr><td>model</td><td><strong>pull</strong> — data over demand</td><td><strong>push</strong> — events over time</td></tr>
      <tr><td>who sets the pace</td><td>the consumer, one <code>next()</code> at a time</td><td>the stream; operators reshape the timing</td></tr>
      <tr><td>you reach for</td><td><code>map</code>, <code>filter</code>, <code>concurrent</code>, <code>toList</code></td><td><code>debounce</code>, <code>throttle</code>, <code>switchMap</code>, <code>combineLatest</code></td></tr>
      <tr><td>backpressure</td><td>yes — nothing is pulled until asked</td><td>no — a stream emits when it emits</td></tr>
    </tbody>
  </table>
  <p>
    The rule of thumb: if the question is <em>&ldquo;how many at once?&rdquo;</em>
    you want the pull chain, because <code>concurrent(n)</code> only means
    something when the consumer controls demand. If the question is
    <em>&ldquo;how often, and which one wins?&rdquo;</em> you want the event
    chain. Start in either and cross over —
    <code>.pull()</code> / <code>.pullLatest()</code> /
    <code>.pullChunked()</code> / <code>.pullNext()</code> turn an
    <code>FxEvents</code> into the pull chain, <code>.toStream()</code> turns
    an <code>FxAsync</code> back into a <code>Stream</code>.
  </p>
  <p>
    Full lessons: <a href="fxEvents.html"><code>fxEvents</code></a> for the
    push chain, <a href="fx.html"><code>fx</code></a> for the chain model and
    the getter spellings, <a href="concurrent.html"><code>concurrent</code></a>
    for the thing only the pull side can do.
  </p>

  <h2>Try it yourself</h2>
  <p>Exercise: keep only the values &gt;= 10 from this stream.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — lift a plain Iterable instead ·
    <a href="asyncVariants.html">async variants</a> — the *Async naming convention ·
    <a href="concurrent.html"><code>concurrent</code></a> — apply before toStream() for real parallelism ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — completion-order variant ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — the push chain; <code>.pull()</code> / <code>.pullLatest()</code> / <code>.pullChunked()</code> / <code>.pullNext()</code> cross back
  </div>
