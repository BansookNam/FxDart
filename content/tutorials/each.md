---
slug: each
title: each — FxDart 101
description: FxDart each tutorial: run a function for its side effects over every element of a lazy chain, sync and async.
heading: <code>each</code>
section: 1
crumb: each
prev: toArray.html
prevLabel: toArray
next: consume.html
nextLabel: consume
---
  <p class="hero-sub">Runs a function once per element, purely for its side effects.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>each</code> is a terminal operator, like <code>toArray</code> —
    calling it pulls every value through the whole chain. The difference is
    what it does with those values: instead of collecting them into a
    <code>List</code>, it just runs <code>f</code> for each one and returns
    <code>void</code>. Use it when you're printing, logging, writing to a
    database, or otherwise producing an effect, and you don't need the
    values back.
  </p>
  <p>
    It's the FxTS-flavored twin of Dart's own <code>Iterable.forEach</code> —
    the same idea, given a name consistent with the rest of the FxTS API so
    it composes naturally with the rest of the chain vocabulary.
  </p>
  <p>
    <code>eachAsync</code> (or <code>.each()</code> on an
    <code>FxAsync</code> chain) awaits <code>f</code> for every element,
    strictly in the order the elements arrive — even if some individual
    calls would finish faster than others, <code>each</code> always
    processes one at a time in sequence. If you want overlap, add
    <code>.concurrent(n)</code> upstream before <code>.each()</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, strictly in order</h2>
  <p>
    Even though each element sleeps for a <em>different</em> length of
    time, <code>eachAsync</code> still processes them 1, 2, 3 — never out
    of order:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>each</code> to print a receipt line for every
    order and keep a running total.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="toArray.html"><code>toArray</code></a> — terminal op that collects a List instead ·
    <a href="consume.html"><code>consume</code></a> — terminal op that discards results and can stop early ·
    <a href="peek.html"><code>peek</code></a> — same idea, but lazy (not terminal) ·
    <a href="fx.html"><code>fx</code></a> — the chain that each terminates
  </div>
