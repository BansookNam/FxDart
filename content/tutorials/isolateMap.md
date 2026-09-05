---
slug: isolateMap
title: isolateMap2..5 — FxDart 101
description: FxDart isolateMap2..5 tutorial: fuse 2–5 CPU stages into one sendable worker so parallel pays one isolate hop, with a live playground.
heading: <code>isolateMap2..5</code>
section: 11
crumb: isolateMap2..5
prev: parallel.html
prevLabel: parallel
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Fuse 2–5 CPU stages into one sendable worker — one isolate hop, not one per stage.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Two
    <code><a href="parallel.html">parallel</a></code>
    calls copy every result back to this isolate and out again. That is
    the same ~5µs hop <code>chunk</code> exists to amortise, paid twice.
    <code>isolateMap3(parse, normalise, score)</code> is one function
    that runs all three on the worker:
  </p>
  <pre><code>await fx(lines)
    .parallel(4, isolateMap3(parse, normalise, score), chunked: true)
    .toList();</code></pre>
  <p>
    Each argument must be sendable (top-level or static, or a closure
    whose captures are). The returned function captures them; it is
    sendable when they are. Dart has no variadic generics, so the
    helpers stop at 5 — like
    <code>zipOrAccumulate2..5</code>. Beyond that, write the fused
    worker yourself.
  </p>
  <p>
    <code>parallel</code> is VM-only, so the playgrounds below run the
    same fused worker through <code>map</code>. The result is identical;
    only the hop is missing.
  </p>

  <h2>Demo 1 · parse, normalise, score</h2>
  <p>
    Three stages, one function. On the VM you would pass this to
    <code>parallel</code>; here it runs in the playground.
  </p>
  {{playground:0}}

  <h2>Demo 2 · Same numbers as three maps</h2>
  <p>
    <code>isolateMap3</code> is composition, not a new operator. Three
    <code>map</code>s and one fused worker print the same list.
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: fuse <code>parse</code> → <code>normalise</code> →
    <code>score</code> and keep only rows that score at least 4.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="parallel.html"><code>parallel</code></a> — the CPU pool this worker is for ·
    <a href="map.html"><code>map</code></a> — the same composition on this isolate ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU ·
    <a href="../parallel-benchmark.html">is parallel worth it?</a> — when the hop matters
  </div>
