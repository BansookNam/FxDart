---
slug: mapEffect
title: mapEffect — FxDart 101
description: FxDart mapEffect tutorial: map used for side effects, with a live playground.
heading: <code>mapEffect</code>
section: 3
crumb: mapEffect
prev: map.html
prevLabel: map
next: flatMap.html
nextLabel: flatMap
---
  <p class="hero-sub">Exactly like map — a naming convention for when the function is really there for its side effect.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Look at the source and you'll find <code>mapEffect</code> is literally
    <code>B mapEffect(f, iterable) =&gt; map(f, iterable);</code> — same
    function, same laziness, same signature. It exists purely to document
    <em>intent</em> at the call site: reach for <code>mapEffect</code> when
    the callback's return value matters less than what it does along the way
    (writing to a log, saving to a database, incrementing a counter), and
    reach for <code>map</code> when the return value is the point.
  </p>
  <p>
    Because it's a plain alias, everything you know about <code>map</code>
    carries over unchanged: it is lazy, it composes with
    <code>.concurrent(n)</code> on the async side, and it has no special
    error handling of its own. There's no behavioral reason to pick one over
    the other — it's a readability signal for the next person (often you)
    reading the pipeline.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>The callback both records a side effect and returns a transformed value —
    same shape as <code>map</code>, different intent at the call site:</p>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  <p>
    <code>mapEffectAsync</code> runs on the exact same engine as
    <code>mapAsync</code>, so <code>.concurrent(n)</code> parallelizes it the
    same way — handy for "process and persist" pipelines:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>mapEffect</code> to <code>print</code> a
    <code>'billing $&lt;dollars&gt;'</code> line for each amount while
    converting cents to dollars.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="map.html"><code>map</code></a> — the function mapEffect delegates to ·
    <a href="peek.html"><code>peek</code></a> — observe without changing the value at all ·
    <a href="flatMap.html"><code>flatMap</code></a> — map + flatten ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
