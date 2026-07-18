---
slug: range
title: range — FxDart 101
description: FxDart range tutorial: a lazy sequence of integers, counting up or down, to pipe into a chain.
heading: <code>range</code>
section: 2
crumb: range
prev: consume.html
prevLabel: consume
next: repeat.html
nextLabel: repeat
---
  <p class="hero-sub">A lazy sequence of integers from start (inclusive) to end (exclusive), stepping by any amount.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>range</code> generates integers on demand, using a <code>sync*</code>
    generator — nothing is allocated up front. Called with one argument,
    <code>range(4)</code> counts <code>0, 1, 2, 3</code> (i.e. <code>0</code>
    up to, but not including, <code>start</code>). Called with two,
    <code>range(1, 4)</code> counts <code>1, 2, 3</code>. A third argument
    sets the step — including a <em>negative</em> step to count downward,
    e.g. <code>range(4, 1, -1)</code> gives <code>4, 3, 2</code>.
  </p>
  <p>
    Because it's lazy, <code>range(1000000)</code> is essentially free to
    create — the million integers only get produced as something downstream
    (usually <code>.take(n)</code>) actually pulls them. This makes
    <code>range</code> the go-to source for demonstrating laziness, and a
    handy stand-in whenever you need "the first N things" without building
    a real collection first.
  </p>
  <p>
    Unlike FxTS's <code>range</code>, which is a finite generator over
    numbers, this port keeps the same finite contract — there's no
    unbounded/infinite form here (that's <code>cycle</code>'s job). If you
    want an endless counter, pair <code>range</code> with <code>cycle</code>
    and <code>take</code>.
  </p>

  <h2>Demo 1 · Counting up, down, and by steps</h2>
  {{playground:0}}

  <h2>Demo 2 · Laziness in a chain</h2>
  <p>
    <code>range(1000000)</code> produces nothing up front — only the 4
    elements <code>take(4)</code> asks for actually run through
    <code>map</code>:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: build the even numbers from 2 to 10 inclusive using
    <code>range</code>'s step argument.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="repeat.html"><code>repeat</code></a> — a fixed value repeated n times ·
    <a href="cycle.html"><code>cycle</code></a> — repeat a whole sequence forever ·
    <a href="take.html"><code>take</code></a> — bound how much of a range you pull ·
    <a href="fx.html"><code>fx</code></a> — the chain range is usually wrapped in
  </div>
