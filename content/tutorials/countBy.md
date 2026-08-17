---
slug: countBy
title: countBy — FxDart 101
description: FxDart countBy tutorial: tally how many elements map to each computed key, with a live playground.
heading: <code>countBy</code>
section: 7
crumb: countBy
prev: indexBy.html
prevLabel: indexBy
next: foldBy.html
nextLabel: foldBy
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
    It is also cheaper than the loop you would write instead. The obvious
    version, <code>counts[k] = (counts[k] ?? 0) + 1</code>, touches the hash map
    <strong>twice</strong> per element — once to read, once to write back — and
    when all you are doing is counting, the map is essentially the whole cost.
    <code>countBy</code> counts into a mutable cell held in the map, so the map
    is written once per <em>distinct key</em> instead of once per element:
    about <strong>1.5× faster</strong> than the hand loop on a million
    elements, and the margin holds from a handful of keys up to tens of
    thousands. <a href="../DartComparison/top-log-level.html">Most frequent log
    level</a> works the number through end to end.
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
