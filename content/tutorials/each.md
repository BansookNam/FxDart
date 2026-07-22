---
slug: each
title: forEach — FxDart 101
description: FxDart forEach tutorial: run a function for its side effects over every element of a lazy chain, sync and async.
heading: <code>forEach</code>
section: 1
crumb: forEach
prev: toList.html
prevLabel: toList
next: consume.html
nextLabel: consume
---
  <p class="hero-sub">Runs a function once per element, purely for its side effects.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>forEach</code> is the Dart-idiomatic name; fxdart also accepts the
    FxTS spelling <code>each</code> — they're the same operator. It's a
    terminal operator, like <code>toList</code> —
    calling it pulls every value through the whole chain. The difference is
    what it does with those values: instead of collecting them into a
    <code>List</code>, it just runs <code>f</code> for each one and returns
    <code>void</code>. Use it when you're printing, logging, writing to a
    database, or otherwise producing an effect, and you don't need the
    values back.
  </p>
  <p>
    On a sync chain, <code>.forEach(f)</code> is Dart's own
    <code>Iterable.forEach</code>, inherited by <code>Fx</code>; the async
    chain and the data-first <code>forEach(f, iterable)</code> form are
    supplied by fxdart so the operator reads the same everywhere.
  </p>
  <p>
    <code>forEachAsync</code> (or <code>.forEach()</code> on an
    <code>FxAsync</code> chain) awaits <code>f</code> for every element,
    strictly in the order the elements arrive — even if some individual
    calls would finish faster than others, <code>forEach</code> always
    processes one at a time in sequence. If you want overlap, add
    <code>.concurrent(n)</code> upstream before <code>.forEach()</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, strictly in order</h2>
  <p>
    Even though each element sleeps for a <em>different</em> length of
    time, <code>forEachAsync</code> still processes them 1, 2, 3 — never out
    of order:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>forEach</code> to print a receipt line for every
    order and keep a running total.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="toList.html"><code>toList</code></a> — terminal op that collects a List instead ·
    <a href="consume.html"><code>consume</code></a> — terminal op that discards results and can stop early ·
    <a href="peek.html"><code>peek</code></a> — same idea, but lazy (not terminal) ·
    <a href="fx.html"><code>fx</code></a> — the chain that forEach terminates
  </div>
