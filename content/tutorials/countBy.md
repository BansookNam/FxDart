---
slug: countBy
title: countBy — FxDart 101
description: FxDart countBy tutorial: tally how many elements map to each computed key, with a live playground.
heading: <code>countBy</code>
section: 7
crumb: countBy
prev: indexBy.html
prevLabel: indexBy
next: sort.html
nextLabel: sort
---
  <p class="hero-sub">Tallies how many elements map to each computed key.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>countBy</code> completes the trio with
    <code><a href="groupBy.html">groupBy</a></code> and
    <code><a href="indexBy.html">indexBy</a></code>: same idea of pulling the
    whole pipeline and computing a key per element, but this time it doesn't
    keep the elements at all — it just increments a counter per key. The
    result is a <code>Map&lt;K, int&gt;</code>: how many elements produced
    each key.
  </p>
  <p>
    Think of the three as answering different questions about the same
    grouping: <code>groupBy</code> — "give me every element for this key",
    <code>indexBy</code> — "give me the last element for this key", and
    <code>countBy</code> — "how many elements had this key?" If all you need
    is the tally, <code>countBy</code> is cheaper than
    <code>groupBy(...).map((k, v) =&gt; MapEntry(k, v.length))</code> since it
    never allocates the intermediate lists.
  </p>
  <p>
    As always, it's a terminal — nothing upstream runs until <code>countBy</code> pulls it.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: count how many votes each candidate received.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — keeps every element instead of just a count ·
    <a href="indexBy.html"><code>indexBy</code></a> — keeps the last element instead of a count ·
    <a href="size.html"><code>size</code></a> — a total count with no key at all
  </div>
