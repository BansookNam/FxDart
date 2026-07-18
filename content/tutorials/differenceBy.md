---
slug: differenceBy
title: differenceBy — FxDart 101
description: FxDart differenceBy tutorial: exclude elements by a computed key found in another iterable, with a live playground.
heading: <code>differenceBy</code>
section: 4
crumb: differenceBy
prev: difference.html
prevLabel: difference
next: intersection.html
nextLabel: intersection
---
  <p class="hero-sub"><code>difference</code>, comparing by a computed key instead of value equality.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>differenceBy(f, iterable1, iterable2)</code> follows the exact
    same argument-order rule as <a href="difference.html"><code>difference</code></a>:
    the result comes <strong>from <code>iterable2</code></strong>, keeping
    only the elements whose <code>f</code>-key does <em>not</em> appear
    among <code>iterable1</code>'s <code>f</code>-keys (with duplicates in
    the result collapsed). The <code>f</code> function is applied to
    <em>both</em> iterables, so — unlike <code>differenceBy</code> in some
    languages — both arguments must share the same element type
    <code>A</code>; only the derived key type <code>B</code> is what's being
    compared.
  </p>
  <p>
    This is the shape you reach for when the "exclusion list" and the
    "source list" are full records rather than bare values: a list of
    blocked user objects and a list of user objects, matched by
    <code>id</code>; or an unavailable-products list and a product catalog,
    matched by <code>sku</code>.
  </p>
  <p>
    <code>difference</code> itself is just
    <code>differenceBy((a) =&gt; a, iterable1, iterable2)</code>. There's no
    chain method for either — call the data-first function directly. On the
    async side, the concurrency marker applies to <code>iterable2</code>,
    same as <code>differenceAsync</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>differenceBy</code> (keyed on <code>'sku'</code>)
    to find products that are still available.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="difference.html"><code>difference</code></a> — the value-equality version ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — keep by a shared computed key instead ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — dedupe a single iterable by key ·
    <a href="compress.html"><code>compress</code></a> — filter by a parallel boolean mask
  </div>
