---
slug: performance
title: Writing fast pipelines — FxDart 101
description: Which FxDart shapes are fast and why — terminal operators, filter order, foldBy over groupBy, and when laziness costs you, with a live playground.
heading: Writing fast pipelines
section: 1
crumb: performance
prev: consume.html
prevLabel: consume
next: range.html
nextLabel: range
---
  <p class="hero-sub">The library can make a shape fast; it cannot pick the shape for you. These are the ones that pay.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Every example in the
    <a href="../DartComparison/index.html">Dart vs FxDart</a> comparison is
    measured against a hand-written imperative loop, and most land at or near
    it. Where a chain is slower, it is almost never the algorithm — both sides
    do the same work — and almost always one of four things: a stage boundary
    paid per element, an allocation per element, a callback run more often than
    it needs to be, or an upstream walked more than once.
  </p>

  <h3>1. End in a terminal operator</h3>
  <p>
    A terminal like <a href="toList.html"><code>toList</code></a> sees the whole
    chain and can take a route no element-by-element consumer can. Over a
    <code>List</code> source, <code>map(f).toList()</code> and
    <code>filter(p).toList()</code> hand the copy to the SDK's own bulk fill,
    which writes the result without the per-element type check that package
    code is forced to pay. Pulling the same chain by hand with a
    <code>for</code>-in and collecting as you go gives up that route entirely.
  </p>

  <h3>2. Filter before you map</h3>
  <p>
    Stages run in the order you write them, and each element that survives a
    <code>filter</code> pays for every stage after it. Putting the cheap test
    first and the expensive transform second is free to do and often the single
    biggest win available.
  </p>

  <h3>3. Ask for the answer, not the ingredients</h3>
  <p>
    <a href="groupBy.html"><code>groupBy</code></a> builds a
    <code>List</code> for every key — allocation proportional to the
    <strong>input</strong> — and if all you wanted was a total per key, those
    lists are built and discarded.
    <a href="foldBy.html"><code>foldBy</code></a> accumulates straight into the
    result map, and <a href="countBy.html"><code>countBy</code></a> is the
    pre-named counter version. Reach for <code>groupBy</code> when you genuinely
    want the members.
  </p>
  <p>
    These two are also the rare case where the operator is faster than the loop
    you would have written. The obvious hand-written line,
    <code>counts[k] = (counts[k] ?? 0) + 1</code>, touches the hash map
    <strong>twice</strong> per element — once to read, once to write back — and
    on a counting workload the map is essentially the whole cost. Both
    operators count into a mutable cell held in the map instead, so the map is
    written once per <em>distinct key</em> rather than once per element:
    ~1.5× on a million-row count, and it is why
    <a href="../DartComparison/top-log-level.html">Most frequent log level</a>
    beats a hand loop rather than trailing it.
  </p>

  <h3>4. A lazy chain re-runs on every pass</h3>
  <p>
    Laziness means the chain is a recipe, not a result: iterate it twice and the
    upstream runs twice. When the answer is used more than once, materialize it
    once — with <a href="toList.html"><code>toList</code></a>, or
    <a href="uniqStrict.html"><code>uniqStrict</code></a> where the dedupe
    itself is the thing you keep.
  </p>

  <h3>What laziness is still buying you</h3>
  <p>
    None of this argues against lazy chains. A <code>take</code> or
    <code>head</code> after a filter stops the source as soon as it has enough
    — the work simply never happens — and that is a category of saving no eager
    pipeline can match. Laziness costs a little per element and can save all of
    it.
  </p>

  <div class="callout">
    <strong>Records are not free.</strong> A stage that produces a record —
    <a href="zip.html"><code>zip</code></a>,
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a>,
    <a href="pairwise.html"><code>pairwise</code></a>, or a
    <code>map</code> to a tuple — allocates one per element, and a record cannot
    be reused. If the very next stage throws most of them away, consider whether
    the pipeline can carry indices or a single value instead;
    <a href="withIndex.html"><code>mapWithIndex</code></a> exists precisely so
    that <code>zipWithIndex().map(...)</code> does not have to allocate a pair
    per element.
  </div>

  <h2>Demo 1 · Terminals and filter order</h2>
  {{playground:0}}

  <h2>Demo 2 · foldBy over groupBy, and paying for a second pass</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: the snippet walks its readings twice and builds a list it throws
    away. Rewrite it as one chain ending in a single terminal operator.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="toList.html"><code>toList</code></a> — the terminal that most fast paths hang off ·
    <a href="foldBy.html"><code>foldBy</code></a> — aggregate without the groups ·
    <a href="uniqStrict.html"><code>uniqStrict</code></a> — dedupe once, reuse many times ·
    <a href="withIndex.html"><code>mapWithIndex</code></a> — the index without the record
  </div>
