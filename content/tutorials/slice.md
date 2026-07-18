---
slug: slice
title: slice — FxDart 101
description: FxDart slice tutorial: pull an index window [start, end) out of an iterable, with a live playground.
heading: <code>slice</code>
section: 5
crumb: slice
prev: dropUntil.html
prevLabel: dropUntil
next: chunk.html
nextLabel: chunk
---
  <p class="hero-sub">Returns the values between index <code>start</code> (inclusive) and <code>end</code> (exclusive).</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>slice</code> is a general index window: it yields the elements
    whose position falls in <code>[start, end)</code>, and omitting
    <code>end</code> means "to the end of the source". It's a single
    operator that subsumes both <code>drop</code> (via <code>start</code>)
    and <code>take</code> (via <code>end</code>) at once.
  </p>
  <p>
    Watch the argument order in the data-first form — unlike most FxDart
    functions, the <code>iterable</code> sits in the <strong>middle</strong>:
    <code>slice(start, iterable, [end])</code>, mirroring FxTS. The chain
    form doesn't have this quirk, since the iterable is the receiver:
    <code>fx(iterable).slice(start, end)</code>. Under the hood
    <code>slice</code> is still just walking the source once and counting
    indices, so it stays lazy and works fine on an infinite source as long
    as you supply an <code>end</code>.
  </p>

  <h2>Demo 1 · Basics &amp; argument order</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>slice</code> to grab the window from index 2 up to
    (not including) index 5.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="drop.html"><code>drop</code></a> — just the start-index half of slice ·
    <a href="take.html"><code>take</code></a> — just the count/end half of slice ·
    <a href="chunk.html"><code>chunk</code></a> — fixed-size windows across the whole source
  </div>
