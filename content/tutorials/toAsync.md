---
slug: toAsync
title: toAsync — FxDart 101
description: FxDart toAsync tutorial: lift a plain Iterable into an FxAsyncIterable and understand the pull-based async model, with a live playground.
heading: <code>toAsync</code>
section: 11
crumb: toAsync
next: asyncVariants.html
nextLabel: async variants
---
  <p class="hero-sub">Lifts a plain Iterable — of values or Futures — into an FxAsyncIterable, the entry point to FxDart's async pipeline.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Every async pipeline in FxDart starts with <code>toAsync</code>. It takes
    a plain <code>Iterable&lt;FutureOr&lt;T&gt;&gt;</code> — a list of plain
    values, a list of Futures, or a mix — and wraps it in an
    <code>FxAsyncIterable</code>, the type every <code>*Async</code> operator
    and the <code>FxAsync</code> chain understand. Whenever an element turns
    out to be a <code>Future</code>, it's awaited automatically as it's pulled.
  </p>
  <p>
    <code>FxAsyncIterable</code> is <strong>pull-based</strong>: nothing runs
    until a terminal (<code>toListAsync</code>, <code>eachAsync</code>, the
    <code>FxAsync</code> chain's <code>.toList()</code>, …) calls
    <code>next()</code> on it, one step at a time — exactly like a plain
    <code>Iterable</code>, just asynchronous. This is a deliberate departure
    from Dart's <code>Stream</code>, which is <em>push</em>-based: once a
    stream starts emitting, it decides the pace, and there's no way for a
    downstream consumer to tell it "evaluate 3 of these at once." FxDart's
    <code>next([Concurrent? concurrent])</code> protocol adds exactly that
    back-channel — a downstream operator like <code>concurrent(n)</code> can
    pass a marker <em>upstream</em> through every pull, asking the source to
    run <code>n</code> items in parallel. Streams have no equivalent hook, which
    is the whole reason FxDart defines its own async iterable instead of
    building on <code>Stream</code>.
  </p>
  <p>
    Use the top-level <code>toAsync(iterable)</code> for a raw
    <code>Iterable&lt;FutureOr&lt;T&gt;&gt;</code>, or the chain method
    <code>fx(iterable).toAsync()</code> to switch an existing <code>Fx</code>
    chain into its <code>FxAsync</code> counterpart. Both are lazy: building
    the pipeline does nothing until something pulls.
  </p>

  <h2>Demo 1 · Values, Futures, and the chain form</h2>
  <p><code>toAsync</code> accepts plain values, Futures, or a mix of both —
    and the chain form does the same thing from an existing <code>Fx</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Why the pull-based model matters</h2>
  <p>
    In Dart, a <code>Future</code> starts running the instant it's created —
    not when it's awaited. So three Futures built eagerly in a list literal
    are already racing before <code>toAsync</code> ever touches them. Contrast
    that with <code>mapAsync</code> (or chain <code>.map</code>), which creates
    one new Future per element only when it's <em>pulled</em> — lazily, one at
    a time, unless you add <code>concurrent(n)</code>:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: filter the list below so only passing scores (&gt;= 60) make
    it into the result.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="asyncVariants.html"><code>*Async</code> naming convention</a> — mapAsync, filterAsync, … ·
    <a href="streams.html">Stream bridges</a> — fromStream, fxStream, toStream ·
    <a href="concurrent.html"><code>concurrent</code></a> — the back-channel in action ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — building async demos
  </div>
