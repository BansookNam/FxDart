---
slug: groupBy
title: groupBy — FxDart 101
description: FxDart groupBy tutorial: bucket every element by a computed key into a Map of Lists, with a live playground.
heading: <code>groupBy</code>
section: 7
crumb: groupBy
prev: join.html
prevLabel: join
next: indexBy.html
nextLabel: indexBy
---
  <p class="hero-sub">Buckets every element into a <code>Map&lt;K, List&lt;A&gt;&gt;</code> by a computed key.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>groupBy</code> is a terminal operator that pulls the whole
    pipeline and sorts each value into a bucket, keyed by whatever
    <code>f</code> returns for it. Every element is kept — nothing is
    dropped, unlike <code><a href="filter.html">filter</a></code> — it's
    just reorganized into buckets.
  </p>
  <p>
    FxTS's version returns a plain JS object; since Dart has no anonymous
    object literal with arbitrary computed keys, FxDart returns a
    <code>Map&lt;K, List&lt;A&gt;&gt;</code> instead — one of the standard
    TS-object-to-Dart-Map conversions used throughout this section
    (<code><a href="indexBy.html">indexBy</a></code> and
    <code><a href="countBy.html">countBy</a></code> do the same).
  </p>
  <p>
    Order matters within each bucket: elements land in each list in the same
    relative order they appeared in the source. And because it's a terminal,
    this works exactly the same whether the upstream pipeline is a plain
    list or a chain of lazy <code>map</code>/<code>filter</code> steps — you
    just pay the cost once, when <code>groupBy</code> pulls it.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: group the words <strong>by their length</strong>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="indexBy.html"><code>indexBy</code></a> — one value per key instead of a list ·
    <a href="countBy.html"><code>countBy</code></a> — count per key instead of collecting ·
    <a href="partition.html"><code>partition</code></a> — grouping into exactly two buckets
  </div>
