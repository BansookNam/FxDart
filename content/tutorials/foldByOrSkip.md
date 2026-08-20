---
slug: foldByOrSkip
title: foldByOrSkip — FxDart 101
description: FxDart foldByOrSkip tutorial: filter and fold-by-key in one strict call whose callback the compiler can inline — with a live playground.
heading: <code>foldByOrSkip</code>
section: 7
crumb: foldByOrSkip
prev: foldBy.html
prevLabel: foldBy
next: countWhere.html
nextLabel: countWhere
---
  <p class="hero-sub">Folds by key like <code>foldBy</code>, except a <code>null</code> key skips the element — so one callback both selects and buckets.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>foldByOrSkip(key, seed, f, xs)</code> is
    <code><a href="filter.html">filter</a></code> +
    <code><a href="foldBy.html">foldBy</a></code> written as a single strict
    call. Everything <code>foldBy</code> guarantees still holds: [seed] starts
    every key rather than running across them, keys come out in first-seen
    order, and the map is probed once per element. The one twist is the key
    function — returning <code>null</code> means "skip this element", the same
    <code>filter_map</code> shape
    <code><a href="takeUniqBy.html">takeUniqBy</a></code> uses.
  </p>
  <p>
    Write <code>filter(...).foldBy(...)</code> by default. Two named steps read
    better than one callback answering two questions, and here the two
    questions are usually unrelated — a date range and a category are not the
    same thought. This operator exists for one reason, and it is worth knowing
    what it is.
  </p>

  <h2>Why it exists: the predicate the compiler cannot see</h2>
  <p>
    <code>filter</code> is a <em>lazy</em> stage, so it keeps its predicate in
    an iterator field. The AOT compiler cannot see through a field, so that
    predicate never inlines — every element pays a real indirect call, and its
    body is never fused into the loop around it. <code>foldBy</code> does not
    have that problem: it is strict, so its callbacks are parameters and get
    inlined into the call site. The filter in front of it is what costs.
  </p>
  <p>
    <code>foldByOrSkip</code> moves the test into the key, which is a
    parameter. Measured over 1,000,000 transactions, AOT, keeping one month in
    twelve:
  </p>
  <table>
    <thead><tr><th>Spelling</th><th>Time</th></tr></thead>
    <tbody>
      <tr><td><code>filter().foldBy()</code></td><td>14.5 ms</td></tr>
      <tr><td><code>foldByOrSkip(…)</code></td><td><strong>12.6 ms</strong></td></tr>
      <tr><td>a hand-written loop</td><td>11.3 ms</td></tr>
    </tbody>
  </table>
  <p>
    Both spellings, and both bars, are on
    <a href="../DartComparison/monthly-category-report.html">Monthly category
    report, sorted by spend</a> — one of the two comparison pages that publish
    three bars instead of two, because the gap between two ways of writing the
    same pipeline is the point they make.
  </p>

  <h2>Demo 1 · July's spend per category</h2>
  {{playground:0}}

  <h2>Demo 2 · The seed, the skip, and what the fold sees</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: the highest reading per sensor, ignoring faulty rows.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="foldBy.html"><code>foldBy</code></a> — the fold this builds on ·
    <a href="filter.html"><code>filter</code></a> — the stage it absorbs ·
    <a href="takeUniqBy.html"><code>takeUniqBy</code></a> — the same idea for <code>filter</code> + <code>uniqBy</code> + <code>take</code> ·
    <a href="performance.html">Performance</a> — where the callback floor comes from
  </div>
