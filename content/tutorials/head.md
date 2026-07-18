---
slug: head
title: head — FxDart 101
description: FxDart head tutorial: grab the first element of an iterable safely, returning null instead of throwing, with a live playground.
heading: <code>head</code>
section: 8
crumb: head
prev: partition.html
prevLabel: partition
next: last.html
nextLabel: last
---
  <p class="hero-sub">Returns the first element of an iterable, or <code>null</code> when it's empty.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>head</code> pulls exactly one element off the front of an iterable
    and hands it back — or <code>null</code> if there isn't one. This is
    FxDart's answer to FxTS's <code>head</code>, which returns
    <code>undefined</code> on an empty array; Dart has no <code>undefined</code>,
    so every "might not exist" result in this corner of the API collapses to
    <code>null</code>. That means the natural way to consume it is
    <code>head(list) ?? fallback</code>.
  </p>
  <p>
    Because <code>head</code> only calls <code>moveNext()</code> once, it
    costs nothing to call on a huge — even infinite — lazy pipeline: nothing
    upstream of it runs beyond the single element it needs.
  </p>
  <p>
    It comes in data-first form (<code>head(iterable)</code>), an async form
    for <code>FxAsyncIterable</code>, and as a chain method
    (<code>fx(iterable).head()</code>) on both the sync and async chains.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>Empty in, <code>null</code> out — no exception, no <code>orElse</code> callback required:</p>
  {{playground:0}}

  <h2>Demo 2 · Laziness, and async short-circuiting</h2>
  <p>
    Only one element is ever pulled from the million-element range below.
    In the async example, the chain awaits the <em>first</em>
    <code>delay(...)</code> and never even bothers with the second:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>head</code> so this prints the first score, or
    <code>0</code> when the list is empty.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="last.html"><code>last</code></a> — same idea from the other end ·
    <a href="nth.html"><code>nth</code></a> — pull any index ·
    <a href="find.html"><code>find</code></a> — first match to a predicate ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — value-based emptiness check
  </div>
