---
slug: fx
title: fx — FxDart 101
description: FxDart fx tutorial: the lazy chain model — fx, fxAsync, fxStream — and how nothing runs until a terminal operator pulls it.
heading: <code>fx</code>
section: 1
crumb: fx
next: pipe.html
nextLabel: pipe
---
  <p class="hero-sub">Wraps a sequence in a lazy, chainable pipeline — the typed heart of FxDart.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Everything in this course builds toward one idea: a <strong>chain</strong>.
    <code>fx(iterable)</code> wraps any <code>Iterable&lt;T&gt;</code> in an
    <code>Fx&lt;T&gt;</code> — an object with FxTS-style methods like
    <code>.map()</code>, <code>.filter()</code>, and <code>.take()</code>
    hung off it. Every one of those calls returns a <em>new</em>
    <code>Fx</code> wrapping a bit more lazy computation. None of it runs
    yet. <code>Fx</code> only starts doing work when you call a
    <strong>terminal operator</strong> — <code>toList()</code>,
    <code>each()</code>, <code>consume()</code>, <code>reduce()</code>, and
    friends — which pulls values through the whole chain, one at a time,
    from the terminal all the way back to the source.
  </p>
  <p>
    This laziness is why FxDart can safely chain over huge or infinite
    sequences (<code>range</code>, <code>cycle</code>, <code>repeat</code>):
    as long as something downstream — usually <code>take(n)</code> — decides
    how many values to actually pull, the upstream steps only ever run that
    many times.
  </p>
  <p>
    <code>fx</code> is the <em>sync</em> half of the chain. Its async
    counterparts are <code>fxAsync</code>, which wraps an
    <code>FxAsyncIterable</code> (the thing you get from <code>toAsync</code>,
    <code>fromStream</code>, or any <code>*Async</code> function), and
    <code>fxStream</code>, a shortcut that wraps a Dart <code>Stream</code>
    directly. Both return an <code>FxAsync&lt;T&gt;</code> chain whose
    methods accept functions that may return a <code>Future</code>, and
    whose terminal operators all return a <code>Future</code> you
    <code>await</code>. Switch from sync to async mid-chain with
    <code>.toAsync()</code>.
  </p>
  <p>
    Why does this exist at all, instead of just calling top-level functions
    like <code>map(f, iterable)</code>? Because Dart cannot type a variadic
    <code>pipe</code> the way FxTS's TypeScript can (see the next lesson) —
    <code>fx()</code> chaining is how FxDart gets fully typed, autocompletable
    pipelines instead.
  </p>

  <h2>Demo 1 · Nothing runs until the terminal op</h2>
  <p>Watch <code>calls</code> stay at 0 right after building the chain, then
    jump once <code>toList()</code> actually pulls the 5 values:</p>
  {{playground:0}}

  <h2>Demo 2 · fxAsync and fxStream</h2>
  <p>
    <code>fxAsync</code> wraps an <code>FxAsyncIterable</code> (here, from
    <code>toAsync</code>); <code>fxStream</code> wraps a <code>Stream</code>
    directly. Both give you the same chain methods, async-flavored:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: build a chain that keeps scores of 60 or above, doubles them
    as bonus points, and takes only the first 2 results.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pipe.html"><code>pipe</code></a> — the dynamically-typed alternative ·
    <a href="toList.html"><code>toList</code></a> — the most common terminal op ·
    <a href="each.html"><code>each</code></a> — terminal op for side effects ·
    <a href="consume.html"><code>consume</code></a> — terminal op that discards results
  </div>
