---
slug: tee3
title: tee3 — FxDart 101
description: FxDart tee3 tutorial: the three-fold form of tee — three reductions over a single pass of a source, with a live playground.
heading: <code>tee3</code>
section: 6
crumb: tee3
prev: tee.html
prevLabel: tee
next: ifEmpty.html
nextLabel: ifEmpty
---
  <p class="hero-sub">Three folds over one pass of a source — <a href="tee.html"><code>tee</code></a> with one more reduction.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>tee3</code> is <a href="tee.html"><code>tee</code></a> with a third
    fold. Everything the <a href="tee.html"><code>tee</code></a> page explains
    holds unchanged — each element advances every accumulator before the next
    one is pulled, so the source is iterated exactly once and nothing is
    buffered; the accumulators are independent and need not share a type; and
    the readers must be folds rather than pipelines. Read that page first for
    the reasoning and for where <a href="fork.html"><code>fork</code></a> is
    the better tool.
  </p>
  <p>
    Dart has no variadic generics, so each arity is its own function — the
    same reason <a href="zip.html"><code>zip</code></a> is joined by
    <code>zip3</code>. Two and three cover the cases worth naming; beyond
    that, fold into a small record or class of your own and use plain
    <a href="fold.html"><code>fold</code></a>.
  </p>

  <h2>Demo · Total, peak and count from one read</h2>
  <p>
    <code>sensor()</code> counts its own values. Three separate passes would
    leave <code>reads</code> at 18; <code>tee3</code> leaves it at 6:
  </p>
  {{playground:0}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="tee.html"><code>tee</code></a> — the two-fold form, and the full explanation ·
    <a href="fork.html"><code>fork</code></a> — independent readers, at the cost of a buffer ·
    <a href="fold.html"><code>fold</code></a> — a single fold
  </div>
