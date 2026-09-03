---
slug: parallel
title: parallel — FxDart 101
description: FxDart parallel tutorial: the CPU twin of concurrent — a pool of isolates, a sendable top-level worker, order kept. VM and Flutter only.
heading: <code>parallel</code>
section: 11
crumb: parallel
prev: using.html
prevLabel: using
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Overlaps CPU work across isolates, in source order. Not <code>concurrent</code> with a different name.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="concurrent.html">concurrent(n)</a></code> overlaps
    <code>Future</code>s on the same isolate — I/O. Dart's CPU-bound story
    is isolates. <code>parallel(n, worker)</code> is the twin: a
    <strong>reused pool</strong> of <code>n</code> isolates, results in
    source order, like <code><a href="mapConcurrent.html">mapConcurrent</a></code>
    is the combined form of map-plus-concurrent.
  </p>
  <table>
    <tr><th></th><th><code>concurrent(n)</code></th><th><code>parallel(n)</code></th></tr>
    <tr><td>What overlaps</td><td><code>Future</code>s on this isolate</td><td>worker isolates</td></tr>
    <tr><td>Callback</td><td>any closure</td><td>top-level or static function</td></tr>
    <tr><td>Values</td><td>anything</td><td>sendable</td></tr>
    <tr><td>Platforms</td><td>VM, Flutter, web</td><td>VM / Flutter only</td></tr>
  </table>
  <p>
    Prefer a top-level or static function. A closure that captures a
    non-sendable (a <code>ReceivePort</code>, an open socket) throws
    <code>ArgumentError</code> at spawn — the isolate contract, not a
    fxdart invention. An unsendable input or result fails that pull the
    same way, rather than hanging. On the web the operator throws
    <code>UnsupportedError</code> — use <code>concurrent(n)</code>
    there. This listing is VM-only and is not a live playground.
  </p>
  <p>
    Don't want to pick <code>n</code>? <code>parallelWorkers</code> is
    the VM's processor count — pass it as the first argument. A
    <code>List</code> shorter than <code>n</code> sizes the pool to the
    list, so <code>parallel(8, w)</code> over two items starts two
    isolates, not eight. People coming from
    <code>mapConcurrent</code> can write <code>mapParallel</code>; it is
    the same operator.
  </p>
  <pre><code>int timesTen(int x) =&gt; x * 10;

Future&lt;void&gt; main() async {
  print(await fx([1, 2, 3, 4]).parallel(2, timesTen).toList());
  // [10, 20, 30, 40]
}</code></pre>

  <div class="callout">
    <strong>Related:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, any closure ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — the combined I/O form ·
    <code>mapParallel</code> — the same operator as <code>parallel</code>
  </div>
