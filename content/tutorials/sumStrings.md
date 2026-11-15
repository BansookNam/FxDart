---
slug: sumStrings
title: sumStrings — FxDart 101
description: FxDart sumStrings tutorial: concatenate every string in one pass with Iterable.join instead of a quadratic fold, with a live playground.
heading: <code>fxSumStrings</code>
section: 7
crumb: sumStrings
prev: join.html
prevLabel: join
next: groupBy.html
nextLabel: groupBy
---
  <p class="hero-sub"><code>sum</code> for strings — concatenation in linear time, not the quadratic fold.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>fxSumStrings(xs)</code> concatenates every string in the iterable,
    with nothing in between. Empty input returns <code>''</code>, the
    identity for concatenation, just as <code>sum</code> of nothing is
    <code>0</code>. It takes a single argument, so it drops straight into a
    <code><a href="pipe.html">pipe</a></code>.
  </p>
  <p>
    The obvious way to write it is
    <code>fold('', (acc, s) =&gt; acc + s, xs)</code> — and that is what
    fxdart once did. But Dart strings are immutable: every <code>+</code>
    copies the whole accumulator into a new string, so the fold's cost grows
    with the <em>square</em> of the output length. <code>fxSumStrings</code>
    is <code>Iterable.join()</code>, which writes each piece once. The
    changelog's measurement, 20,000 strings of 10 characters:
    <strong>74,620 µs → 343 µs</strong>.
  </p>
  <p>
    There is no chain member and no async twin. On a sync chain,
    <code>fx(xs).join()</code> is the same call — <code>Fx.join</code> is
    Dart's <code>Iterable.join</code>, whose default separator is
    <code>''</code>. On <code>FxAsync</code>, <code>join</code> defaults to
    <code>','</code> (the FxTS default), so spell the empty separator out:
    <code>.join('')</code>.
  </p>

  <h2>Demo 1 · Basics, and the fold it replaces</h2>
  {{playground:0}}

  <h2>Demo 2 · On a chain, sync and async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: replace the quadratic fold with one call.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="join.html"><code>join</code></a> — the same, with a separator ·
    <a href="sum.html"><code>sum</code></a> — the numeric version ·
    <a href="fold.html"><code>fold</code></a> — why not to concatenate with it
  </div>
