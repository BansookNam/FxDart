---
slug: max
title: max — FxDart 101
description: FxDart max tutorial: the largest number in a pipeline, -infinity when empty, NaN-poisoned, with a live playground.
heading: <code>max</code>
section: 7
crumb: max
prev: min.html
prevLabel: min
next: maxBy.html
nextLabel: maxBy
---
  <p class="hero-sub">The largest number in the pipeline — the mirror image of <code>min</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>max</code> works exactly like <code><a href="min.html">min</a></code>,
    flipped: it's <code>fold(-double.infinity, ..., iterable)</code>, keeping
    the largest value seen so far.
  </p>
  <p>
    The same two FxTS-faithful quirks apply, just mirrored:
  </p>
  <ul>
    <li>An <strong>empty</strong> iterable returns <code>-double.infinity</code>, not <code>null</code>.</li>
    <li>A single <code>NaN</code> anywhere <strong>poisons</strong> the result to <code>NaN</code> — same reasoning as <code>min</code>: every comparison against <code>NaN</code> is false.</li>
  </ul>
  <p>
    As with the other numeric terminals, the chain form
    (<code>Fx&lt;num&gt;.max()</code> / <code>FxAsync&lt;num&gt;.max()</code>)
    is only available when the compiler knows your chain holds numbers.
  </p>

  <h2>Demo 1 · Basics, empty, and NaN</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: find the <strong>highest</strong> temperature in the list.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="min.html"><code>min</code></a> — the mirror image ·
    <a href="sum.html"><code>sum</code></a> · <a href="average.html"><code>average</code></a> — the other numeric terminals ·
    <a href="sortBy.html"><code>sortBy</code></a> — to rank rather than just find the extreme
  </div>
