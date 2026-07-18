---
slug: chunk
title: chunk — FxDart 101
description: FxDart chunk tutorial: batch a lazy iterable into fixed-size lists, with a live playground.
heading: <code>chunk</code>
section: 5
crumb: chunk
prev: slice.html
prevLabel: slice
next: split.html
nextLabel: split
---
  <p class="hero-sub">Returns a lazy iterable of lists, each holding up to <code>size</code> consecutive elements.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>chunk</code> batches a flat sequence into fixed-size groups —
    dealing cards into hands, paginating a result set, sending work to a
    downstream API in batches of <code>n</code>. It buffers just
    <code>size</code> elements at a time before yielding each list, so it
    stays lazy and memory-bounded even over a huge source; only the final
    chunk is allowed to come up short, if the source doesn't divide evenly.
  </p>
  <p>
    The async version, <code>chunkAsync</code>, awaits <code>size</code>
    elements before producing each chunk — pair it with
    <code>.concurrent(n)</code> upstream to fill a chunk's worth of async
    work concurrently.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>10 items chunked by 3 leaves a shorter final chunk:</p>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: deal the cards into hands of 3.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="slice.html"><code>slice</code></a> — a single arbitrary window instead of repeated batches ·
    <a href="split.html"><code>split</code></a> — group by separator instead of fixed size ·
    <a href="transpose.html"><code>transpose</code></a> — flip rows and columns of already-chunked data
  </div>
