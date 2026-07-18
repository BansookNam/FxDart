---
slug: pluck
title: pluck — FxDart 101
description: FxDart pluck tutorial: pull one field out of a list of maps, with a live playground.
heading: <code>pluck</code>
section: 3
crumb: pluck
prev: peek.html
prevLabel: peek
next: filter.html
nextLabel: filter
---
  <p class="hero-sub">Extracts the value under one key from every map in an iterable — a one-liner for the common "get me just this field" query.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>pluck</code> is a tiny, named specialization of
    <code>map</code> — literally <code>map((a) =&gt; a[key], iterable)</code>
    under the hood. It exists because "grab one field from a list of
    records" is common enough to deserve its own name, and reads better at
    a call site than a one-off lambda.
  </p>
  <p>
    Notice the return type is <code>Iterable&lt;V?&gt;</code>, not
    <code>Iterable&lt;V&gt;</code>: a <code>Map</code> lookup can never
    guarantee the key is present, so a missing key becomes <code>null</code>
    in the result rather than throwing. If you need to drop those nulls
    afterward, chain into <a href="compact.html"><code>compact</code></a>.
  </p>
  <p>
    There is <strong>no chain method</strong> for <code>pluck</code> on
    <code>Fx</code>/<code>FxAsync</code> — only the data-first top-level
    function exists. Call it directly on your source, or wrap the result
    with <code>fx(...)</code>/<code>fxAsync(...)</code> to keep chaining
    afterward.
  </p>

  <h2>Demo 1 · Basics &amp; missing keys</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  <p>
    <code>pluckAsync</code> is built directly on <code>mapAsync</code>, so
    fetch the records concurrently first, then pluck what you need:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>pluck</code> to get a list of just the product
    titles.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="map.html"><code>map</code></a> — the general form pluck specializes ·
    <a href="compact.html"><code>compact</code></a> — drop the nulls pluck can produce ·
    <a href="../tutorials/prop.html"><code>prop</code></a> — pluck's single-map cousin ·
    <a href="filter.html"><code>filter</code></a> — keep matching elements
  </div>
