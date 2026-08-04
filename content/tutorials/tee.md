---
slug: tee
title: tee — FxDart 101
description: FxDart tee tutorial: run two or three folds over a single pass of a source, with no buffering, plus a live playground.
heading: <code>tee</code>
section: 6
crumb: tee
prev: fork.html
prevLabel: fork
next: tee3.html
nextLabel: tee3
---
  <p class="hero-sub">Runs several folds over one pass of a source — one iteration, nothing buffered.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Two questions about the same data usually cost two passes:
    <code>readings.fold(...)</code> for the total, then
    <code>readings.reduce(...)</code> for the peak. That is fine for a
    <code>List</code>, and wrong for anything else — a <code>sync*</code>
    generator, a network page, a source that counts how often it ran will
    all be walked twice. <code>tee</code> asks both questions at once:
    each element advances the total <em>and</em> the peak before the next
    one is pulled, so the source is iterated exactly once.
  </p>
  <p>
    A reader is given as a <strong>fold</strong> — a record of
    <code>seed</code> (where it starts) and <code>step</code> (how one
    element advances it). That shape is what makes the single pass free.
    Because both readers move together, element by element, there is never
    a value that one has seen and the other has not, so there is nothing
    to remember: <code>tee</code> over a million elements holds two
    accumulators, not a million values. The two accumulators are entirely
    independent and need not share a type. <code>tee3</code> takes three.
  </p>
  <p>
    The constraint is the price of that. <code>tee</code> feeds folds, not
    pipelines — the readers cannot advance at their own pace, take
    different amounts, or stop early independently. When you genuinely need
    two <em>independent</em> readers, reach for
    <a href="fork.html"><code>fork</code></a> instead, and accept the shared
    buffer it keeps so a lagging cursor can catch up. Rule of thumb: if both
    readers consume the whole source and reduce it to a value,
    <code>tee</code>; if either one is a pipeline in its own right,
    <code>fork</code>.
  </p>

  <h2>Where the name comes from</h2>
  <p>
    <code>tee</code> is not an abbreviation — it is the letter <strong>T</strong>,
    borrowed from the T-splitter used in plumbing. A T-fitting branches one
    pipe into two, so what flows in one way leaves two ways at once. Unix
    took the image for its <code>tee</code> command, which reads standard
    input and sends it to standard output <em>and</em> a file at the same
    time:
  </p>
  <pre><code>       input
        │
        ▼
    ┌───┴───┐
    │  tee  │
    └───┬───┘
   ┌────┴────┐
   ▼         ▼
  stdout    file</code></pre>
  <p>
    Python's <code>itertools.tee()</code> borrows the same picture, splitting
    one iterable into several independent iterators. Worth knowing, because
    that is the part FxDart spells <a href="fork.html"><code>fork</code></a>,
    not <code>tee</code>: <code>fork</code> gives you independent cursors,
    the way Python's does. FxDart's <code>tee</code> branches the
    <em>consumption</em> instead — one pass, several folds reading it in
    step. Same T-shaped picture, split one level further downstream.
  </p>

  <h2>Demo 1 · Total and peak from one read</h2>
  <p>
    <code>sensor()</code> increments <code>reads</code> for every value it
    produces. Two separate passes would leave <code>reads</code> at 12;
    <code>tee</code> leaves it at 6:
  </p>
  {{playground:0}}

  <h2>Demo 2 · Independent accumulators, tee3, and on a chain</h2>
  <p>
    The two folds carry unrelated types — an <code>int</code> character
    count beside a <code>String</code> running winner. <code>tee3</code>
    adds a third fold, and on an <code>fx</code> chain the folds see what
    the <em>chain</em> produces, not the original source:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: <code>sensor()</code> is currently walked twice, so
    <code>reads</code> prints 6. Replace the two passes with a single
    <code>tee</code> — summing in one fold and counting in the other — so
    that <code>reads</code> prints 3.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fork.html"><code>fork</code></a> — independent readers, at the cost of a buffer ·
    <a href="reduce.html"><code>reduce</code></a> — a single fold ·
    <a href="groupBy.html"><code>groupBy</code></a> — many accumulators keyed by value
  </div>
