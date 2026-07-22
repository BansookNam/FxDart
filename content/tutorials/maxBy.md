---
slug: maxBy
title: maxBy — FxDart 101
description: FxDart maxBy tutorial: the element with the largest key in one walk — no sort, null when empty — with a live playground.
heading: <code>maxBy</code>
section: 7
crumb: maxBy
prev: max.html
prevLabel: max
next: minBy.html
nextLabel: minBy
---
  <p class="hero-sub">The element whose key is largest — one walk, no sort, <code>null</code> when empty.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>maxBy</code> answers "which <em>element</em> has the biggest
    key?" — not "what is the biggest number?" (that's
    <code><a href="max.html">max</a></code>). It walks the pipeline
    <strong>once</strong>, keeping the current best element, so it is O(n)
    where the tempting <code>sortBy(key).head()</code> shape pays
    O(n&nbsp;log&nbsp;n) and materializes a sorted list it never needs.
  </p>
  <p>
    Keys are compared exactly like
    <code><a href="sortBy.html">sortBy</a></code> compares them
    (<code>Comparable.compare</code>), and on ties the <strong>first</strong>
    element encountered wins — so <code>maxBy</code> over a date-sorted list
    gives you the earliest of the equally-largest.
  </p>
  <p>
    Empty input returns <code>null</code>, like
    <code><a href="head.html">head</a></code> and
    <code><a href="last.html">last</a></code> — Dart's nullable types replace
    FxTS's <code>undefined</code> here. This is a Dart-native addition
    (FxTS only ships the numeric <code>max</code>); the name follows
    Kotlin's <code>maxByOrNull</code> shape.
  </p>

  <h2>Demo 1 · Basics, empty case &amp; ties</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: find the biggest expense <strong>without sorting</strong>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="minBy.html"><code>minBy</code></a> — the mirror image ·
    <a href="max.html"><code>max</code></a> — when you want the key itself, not the element ·
    <a href="sortBy.html"><code>sortBy</code></a> — when you need the full ordering anyway
  </div>
