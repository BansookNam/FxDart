---
slug: countWhere
title: countWhere — FxDart 101
description: FxDart countWhere tutorial: count the matching values in one walk — filter plus size fused — with a live playground.
heading: <code>countWhere</code>
section: 7
crumb: countWhere
prev: foldBy.html
prevLabel: foldBy
next: sort.html
nextLabel: sort
---
  <p class="hero-sub">How many match? One walk, one number — <code>filter</code> + <code>size</code>, fused.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    "How many of these are overdue / on sale / even?" kept getting written
    as <code>filter(pred).size()</code> — two chain steps and a lazy
    intermediate for what is conceptually a single fold.
    <code>countWhere(pred)</code> is that fold: it walks the pipeline once,
    increments on each match, and returns the count. Nothing is
    materialized along the way.
  </p>
  <p>
    Reach for <code><a href="countBy.html">countBy</a></code> when you want
    counts <em>per key</em> (a map of them), and <code>countWhere</code>
    when one predicate's count is the whole answer. The async twin awaits
    its predicate per element, like every <code>*Async</code> operator.
  </p>
  <p>
    Dart-native addition — the shape of Kotlin's <code>count { }</code>.
  </p>

  <h2>Demo 1 · One predicate, one number</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: count the fallback prices without a <code>filter</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="countBy.html"><code>countBy</code></a> — counts per key ·
    <a href="count.html"><code>size</code>/<code>count</code></a> — count everything ·
    <a href="filter.html"><code>filter</code></a> — when you need the matches themselves
  </div>
