---
slug: unzip
title: unzip — FxDart 101
description: FxDart unzip tutorial: split an iterable of pairs into two lists in one pass — the inverse of zip — with a live playground.
heading: <code>fxUnzip</code>
section: 6
crumb: unzip
prev: zipWith.html
prevLabel: zipWith
next: zipWithIndex.html
nextLabel: indexed
---
  <p class="hero-sub">Pairs in, two lists out — the inverse of <code>zip</code>, in a single pass.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="zip.html">zip</a></code> pairs two iterables up;
    <code>fxUnzip(pairs)</code> takes them apart again. It returns a record
    <code>(lefts, rights)</code> — two <code>List</code>s, filled side by
    side in one walk over the input — so the usual way in is a destructuring
    declaration: <code>final (names, scores) = fxUnzip(pairs);</code>. The
    long-hand, two <code>map</code>s over the same pairs, walks the input
    twice.
  </p>
  <p>
    The round trip holds up to length: <code>fxUnzip(fxZip(a, b))</code>
    gives back <code>a</code> and <code>b</code>, truncated to the shorter
    of the two, because <code>zip</code> already dropped the rest. Empty
    input gives two empty lists. Unlike most of section 6,
    <code>unzip</code> is <strong>strict</strong>, and has to be: a lazy one
    would hand back two iterables over one source, and draining either
    would buffer everything the other had not reached yet (the cost
    <code><a href="fork.html">fork</a></code> pays).
  </p>
  <p>
    <code>fxUnzipAsync</code> drains an <code>FxAsyncIterable</code> of
    pairs into a <code>Future</code> of the same record. On the chain it is
    <code>.unzip()</code> — an extension on <code>Fx&lt;(A, B)&gt;</code>
    and <code>FxAsync&lt;(A, B)&gt;</code>, so it appears only on chains of
    positional pairs, such as the ones <code>zip</code>,
    <code><a href="attach.html">attach</a></code> and
    <code><a href="pairwise.html">pairwise</a></code> produce. Dart-native addition (FxTS has no
    <code>unzip</code>); Kotlin and Rust spell it the same.
  </p>

  <h2>Demo 1 · Pairs into two lists</h2>
  {{playground:0}}

  <h2>Demo 2 · Closing an async chain</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: split the points in one pass.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="zip.html"><code>zip</code></a> — the other direction ·
    <a href="zipWith.html"><code>zipWith</code></a> — zip and combine in one step ·
    <a href="partition.html"><code>partition</code></a> — two lists split by a predicate ·
    <a href="attach.html"><code>attach</code></a> — builds the pairs to unzip
  </div>
