---
slug: reduceLazy
title: reduceLazy — FxDart 101
description: FxDart reduceLazy tutorial: build a reusable reducer function you can apply to many iterables, with a live playground.
heading: <code>reduceLazy</code>
section: 7
crumb: reduceLazy
prev: fold.html
prevLabel: fold
next: sum.html
nextLabel: sum
---
  <p class="hero-sub">Curries fold's seed and combiner into a reusable reducer function.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>reduceLazy</code> doesn't reduce anything by itself — it
    <strong>builds a reducer</strong>. Give it a combining function and a
    seed, and you get back a plain function of type
    <code>Iterable&lt;A&gt; Function</code> that you can call as many times
    as you like, against as many different iterables as you like, without
    repeating the seed and combiner every time.
  </p>
  <p>
    Under the hood it's just a thin wrapper around
    <code><a href="fold.html">fold</a></code>:
    <code>reduceLazy(f, seed)</code> returns
    <code>(iterable) =&gt; fold(seed, f, iterable)</code>. Notice the argument
    order flips relative to <code>fold</code> — here it's
    <code>(f, seed)</code>, matching FxTS's curried style, where the
    iterable is deliberately left off until later.
  </p>
  <p>
    This is a plain (uncurried-beyond-this) Dart function, so there's no
    <code>Fx</code> chain method or <code>*Async</code> counterpart for it —
    but the function it returns happens to accept anything that implements
    <code>Iterable&lt;A&gt;</code>, which includes <code>Fx&lt;A&gt;</code>.
    That means you can drop it straight into <code>.to(...)</code> on a chain.
  </p>

  <h2>Demo 1 · A reusable summer</h2>
  {{playground:0}}

  <h2>Demo 2 · Reused across different lists</h2>
  <p>The whole point is defining the "how to combine" once and reusing it everywhere:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: build a reusable reducer with <code>reduceLazy</code> that finds the <strong>max</strong> value.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fold.html"><code>fold</code></a> — the seeded reducer this wraps ·
    <a href="reduce.html"><code>reduce</code></a> — the unseeded terminal ·
    <a href="pipe.html"><code>pipe</code></a> — compose functions like this into a pipeline ·
    <a href="memoize.html"><code>memoize</code></a> — another way to build a reusable function
  </div>
