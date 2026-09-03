---
slug: concurrentOrParallel
title: concurrent or parallel — FxDart 101
description: FxDart concurrent or parallel tutorial: when to overlap Futures on this isolate, and when to send CPU work to a pool of isolates.
heading: concurrent or parallel
section: 11
crumb: concurrent or parallel
prev: using.html
prevLabel: using
next: parallel.html
nextLabel: parallel
---
  <p class="hero-sub">Two ways to overlap work. They are not the same operator with two names.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="concurrent.html">concurrent(n)</a></code> overlaps
    <code>Future</code>s on <em>this</em> isolate — I/O, waiting.
    <code><a href="parallel.html">parallel(n, worker)</a></code> overlaps
    CPU work across <em>other</em> isolates. Pick by what the callback
    spends its time doing, not by how much you want to "go faster."
  </p>
  <table>
    <tr><th></th><th><code>concurrent(n)</code></th><th><code>parallel(n)</code></th></tr>
    <tr><td>What overlaps</td><td><code>Future</code>s on this isolate</td><td>worker isolates</td></tr>
    <tr><td>Callback</td><td>any closure</td><td>top-level or static function</td></tr>
    <tr><td>Values</td><td>anything</td><td>sendable</td></tr>
    <tr><td>Platforms</td><td>VM, Flutter, web</td><td>VM / Flutter only</td></tr>
    <tr><td>Cheap work (<code>x + 1</code>, <code>Future.delayed(0)</code>)</td><td>a marker; hops are cheap</td><td>an isolate message per item — usually a loss</td></tr>
    <tr><td>The right job</td><td>HTTP, DB, files, <code>await</code></td><td>JSON parse, images, crypto, a tight loop</td></tr>
  </table>
  <p>
    I/O is mostly waiting. While a request is in flight the isolate is
    idle, so overlapping four <code>Future</code>s with
    <code>concurrent(4)</code> cuts wall-clock time and does not need
    another isolate. CPU work <em>is</em> the isolate: it blocks the
    event loop (and a Flutter frame) until it returns. That is what
    <code>parallel</code> is for.
  </p>
  <p>
    The isolate hop is not free. Each item is serialized, sent, run,
    serialized back, and reordered. A callback whose body is
    <code>x + 1</code> spends more time in that hop than in the
    addition — four workers then make it <em>slower</em> than one,
    because you pay four times the postage for no CPU to reclaim.
    Measured: a thousand <code>x + 1</code>s on four workers took
    about twice as long as on one; a tight 20000-iteration loop
    on four workers was about twice as <em>fast</em> as on one. If the
    work is not heavier than the hop, stay on this isolate.
  </p>
  <pre><code>// I/O — overlap Futures here
fx(ids).mapConcurrent(8, fetchUser);

// CPU — only when the body is heavy enough
fx(blobs).parallel(parallelWorkers, parseJson);

// This is a loss. The hop is bigger than the work.
fx(nums).parallel(4, (x) =&gt; x + 1);</code></pre>

  <div class="callout">
    <strong>Related:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, any closure ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — the combined I/O form ·
    <a href="parallel.html"><code>parallel</code></a> — CPU, sendable worker ·
    <a href="parallel.html"><code>mapParallel</code></a> — alias of <code>parallel</code>
  </div>
