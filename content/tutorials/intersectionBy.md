---
slug: intersectionBy
title: intersectionBy — FxDart 101
description: FxDart intersectionBy tutorial: keep elements by a computed key shared with another iterable, with a live playground.
heading: <code>intersectionBy</code>
section: 4
crumb: intersectionBy
prev: intersection.html
prevLabel: intersection
next: compress.html
nextLabel: compress
---
  <p class="hero-sub"><code>intersection</code>, comparing by a computed key instead of value equality.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Same shape as <a href="differenceBy.html"><code>differenceBy</code></a>,
    opposite condition: <code>intersectionBy(f, iterable1, iterable2)</code>
    walks <strong><code>iterable2</code></strong> and keeps each element
    whose <code>f</code>-key <em>is</em> found among <code>iterable1</code>'s
    <code>f</code>-keys, deduplicated by that key. <code>f</code> applies to
    both iterables, so both must share the same element type <code>A</code>
    — only the comparison key type <code>B</code> can differ from
    <code>A</code>.
  </p>
  <p>
    This is the natural match for two lists of full records that share an
    identifying field: a list of "featured" SKUs and a product catalog, a
    list of active-user IDs and a list of full user objects, and so on.
    <code>intersection</code> itself is
    <code>intersectionBy((a) =&gt; a, iterable1, iterable2)</code>.
  </p>
  <p>
    No chain method exists; call the data-first function or its async
    counterpart. The concurrency marker from <code>.concurrent(n)</code>
    applies to <code>iterable2</code>, exactly as with
    <code>intersectionAsync</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>intersectionBy</code> (keyed on <code>'sku'</code>)
    to find products that are on sale.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="intersection.html"><code>intersection</code></a> — the value-equality version ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — exclude by a shared computed key instead ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — dedupe a single iterable by key ·
    <a href="compress.html"><code>compress</code></a> — filter by a parallel boolean mask
  </div>
