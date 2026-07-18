---
slug: reduce
title: reduce — FxDart 101
description: FxDart reduce tutorial: fold a pipeline down to one value using its first element as the seed, with a live playground.
heading: <code>reduce</code>
section: 7
crumb: reduce
prev: fork.html
prevLabel: fork
next: fold.html
nextLabel: fold
---
  <p class="hero-sub">Collapses a pipeline into a single value, using its first element as the starting seed.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>reduce</code> is a <strong>terminal</strong> operator: unlike
    <code>map</code> or <code>filter</code>, calling it immediately pulls
    every value through the whole lazy pipeline behind it and produces one
    concrete result. Nothing upstream runs until you call a terminal like
    this one.
  </p>
  <p>
    This is the <em>unseeded</em> form: it takes the first element of the
    iterable as the starting accumulator, then combines the rest into it.
    Because of that, calling it on an empty iterable makes no sense — there's
    no first element to seed with — so it throws a <code>StateError</code>.
  </p>
  <p>
    FxTS overloads <code>reduce</code> for both the seeded and unseeded case
    by argument count — <code>reduce(f, iterable)</code> vs.
    <code>reduce(f, seed, iterable)</code>. Dart has no arity-based
    overloading, so FxDart keeps <code>reduce</code> for the unseeded form
    and renames the seeded one to <code><a href="fold.html">fold</a></code> —
    matching Dart's own <code>Iterable.fold</code> naming. If you have a seed,
    reach for <code>fold</code>.
  </p>
  <p>
    On the sync chain, <code>Fx</code> extends <code>Iterable</code>, so
    <code>.reduce(f)</code> is simply Dart's built-in method — same contract,
    same <code>StateError</code> on empty. On the async chain,
    <code>FxAsync.reduce</code> is spelled out explicitly and awaits each
    combine step.
  </p>

  <h2>Demo 1 · Basics &amp; the empty-input error</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  <p>
    <code>reduce</code> still pulls the whole pipeline behind it — including
    a <code>.concurrent(n)</code> stage, which evaluates <code>n</code>
    upstream values at a time while <code>reduce</code> combines them as they
    arrive in order:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>reduce</code> to find the <strong>longest</strong> word in the list.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fold.html"><code>fold</code></a> — the seeded counterpart ·
    <a href="reduceLazy.html"><code>reduceLazy</code></a> — a reusable, curried reducer ·
    <a href="sum.html"><code>sum</code></a> — reduce specialized for numbers ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation upstream
  </div>
