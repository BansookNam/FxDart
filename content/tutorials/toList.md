---
slug: toList
title: toList — FxDart 101
description: FxDart toList tutorial: the terminal operator that materializes a lazy chain into a List, sync and async.
heading: <code>toList</code>
section: 1
crumb: toList
prev: pipe1.html
prevLabel: pipe1
next: each.html
nextLabel: each
---
  <p class="hero-sub">Materializes a lazy iterable — pulling every value and collecting them into a List.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>toList</code> is the workhorse <strong>terminal operator</strong>:
    it's what actually runs a chain that was, until this point, nothing but
    a plan. Calling <code>.toList()</code> pulls every remaining value out
    of the iterable, in order, and collects them into a real
    <code>List&lt;T&gt;</code>. Everything upstream — every <code>.map()</code>,
    <code>.filter()</code>, <code>.take()</code> — only runs because
    <code>toList</code> asked for values.
  </p>
  <p>
    That also means <code>toList</code> is exactly the operator you must
    <em>not</em> call directly on an infinite or unbounded source
    (<code>range</code> with no end, <code>cycle</code>, <code>repeat</code>
    with a huge count) — it will try to pull forever. Bound it first with
    <code>take(n)</code>, then call <code>toList</code> on the bounded
    result.
  </p>
  <p>
    The async version, <code>toListAsync</code> (or <code>.toList()</code>
    on an <code>FxAsync</code> chain), awaits each element as it's pulled
    and returns a <code>Future&lt;List&lt;T&gt;&gt;</code>. Combined with
    <code>.concurrent(n)</code> upstream, the individual awaits can overlap
    even though the final list still comes back in the original order.
  </p>

  <h2>Demo 1 · Basics &amp; laziness</h2>
  <p>Note how <code>map</code> only actually runs for the 3 values that
    <code>take(3)</code> allows through — out of a million:</p>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  <p>
    <code>.toList()</code> on an <code>FxAsync</code> chain awaits every
    element and hands back the whole list at once; add
    <code>.concurrent(n)</code> upstream to overlap the individual waits:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: materialize the first 4 squares of a huge range into a List.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="each.html"><code>each</code></a> — terminal op for side effects instead of a List ·
    <a href="consume.html"><code>consume</code></a> — terminal op that discards results entirely ·
    <a href="fx.html"><code>fx</code></a> — the chain that toList terminates ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
