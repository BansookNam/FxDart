---
slug: find
title: firstWhereOrNull — FxDart 101
description: FxDart firstWhereOrNull tutorial: get the first element matching a predicate, lazy and short-circuiting, null when nothing matches.
heading: <code>firstWhereOrNull</code>
section: 8
crumb: firstWhereOrNull
prev: nth.html
prevLabel: nth
next: findIndex.html
nextLabel: findIndex
---
  <p class="hero-sub">Returns the first element for which a predicate is true, or <code>null</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>firstWhereOrNull</code> is the Dart-idiomatic name; fxdart also
    accepts the FxTS spelling <code>find</code> — they're the same operator.
    It's what <code>head</code> and <code>filter</code>
    look like fused together — in fact it's implemented as exactly that:
    <code>head(filter(f, iterable))</code>. That fusion is what makes it
    lazy and short-circuiting: it pulls elements one at a time, testing each
    against <code>f</code>, and stops the instant it finds a match. Nothing
    further downstream is ever touched.
  </p>
  <p>
    Just like <code>head</code>, an unmatched search returns <code>null</code>
    rather than FxTS's <code>undefined</code>. It's available data-first,
    as an async variant, and as a method on both the sync and async chains.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Short-circuiting &amp; async</h2>
  <p>Only 6 of a million elements are ever checked:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>firstWhereOrNull</code> to get the first item with <code>qty &gt; 0</code>, or <code>null</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="findIndex.html"><code>findIndex</code></a> — same search, returns a position ·
    <a href="filter.html"><code>filter</code></a> — every match, not just the first ·
    <a href="head.html"><code>head</code></a> — what <code>find</code> is built from ·
    <a href="matches.html"><code>matches</code></a> — a ready-made shape-matching predicate
  </div>
