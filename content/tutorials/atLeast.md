---
slug: atLeast
title: atLeast — FxDart 101
description: FxDart atLeast and atMost tutorial: count matches only as far as the answer needs, stopping at the deciding element, sync and async.
heading: <code>atLeast</code> · <code>atMost</code>
section: 8
crumb: atLeast
prev: some.html
prevLabel: any
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">"Are there at least n?" — answered by stopping at the nth match instead of counting everything.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>countWhere(f) &gt;= 2</code> reads well and walks the whole
    input, even when the second match is the second element.
    <code>atLeast(n, f)</code> asks the same question and stops at the
    <code>n</code>th match; <code>atMost(n, f)</code> stops at the
    <code>n + 1</code>th, which is the moment its answer becomes
    <code>false</code>. On a long or lazy input — a range, a mapped
    pipeline, a stream of rows — the rest is never pulled.
  </p>
  <p>
    They extend the quantifiers you already have.
    <code>atLeast(1, f)</code> is <code><a href="some.html">any</a></code>
    and <code>atMost(0, f)</code> is <code>none</code>; the edges are
    defined so that holds — <code>atLeast</code> with <code>n &lt;= 0</code>
    is <code>true</code> and <code>atMost</code> with a negative
    <code>n</code> is <code>false</code>, both without reading anything. The
    async forms cancel upstream at the deciding match, like
    <code>any</code>. fxdart extension (not part of FxTS).
  </p>

  <h2>Demo 1 · Stop at the nth match</h2>
  {{playground:0}}

  <h2>Demo 2 · atMost, the edges, async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: decide the vote without counting every ballot.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="some.html"><code>any</code></a> — <code>atLeast(1, f)</code> ·
    <a href="every.html"><code>every</code></a> — the universal quantifier ·
    <a href="countWhere.html"><code>countWhere</code></a> — when you need the exact count
  </div>
