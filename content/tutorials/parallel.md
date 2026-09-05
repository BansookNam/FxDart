---
slug: parallel
title: parallel — FxDart 101
description: FxDart parallel tutorial: the CPU twin of concurrent — a pool of isolates, a sendable top-level worker, order kept, and chunk to amortise the isolate hop. VM and Flutter only.
heading: <code>parallel</code>
section: 11
crumb: parallel
prev: concurrentOrParallel.html
prevLabel: concurrent or parallel
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
    is the combined form of map-plus-concurrent. They are not the same
    operator — the comparison lives on
    <a href="concurrentOrParallel.html">concurrent or parallel</a>.
  </p>
  <p>
    Prefer a top-level or static function. A closure that captures a
    non-sendable (a <code>ReceivePort</code>, an open socket) throws
    <code>ArgumentError</code> at spawn — the isolate contract, not a
    fxdart invention. An unsendable input or result fails that pull the
    same way, rather than hanging. On the web the operator throws
    <code>UnsupportedError</code> — use <code>concurrent(n)</code>
    there. This listing is VM-only and is not a live playground.
    The worker may return a <code>Future</code>
    (<code>FutureOr</code>, same shape as
    <code>mapConcurrent</code>) — a sync callback is still the fast
    path. Nested <code>parallel</code> inside an async worker is
    allowed: that isolate spawns its own pool, and cancel of the outer
    chain shuts the nested pool down. One level of nesting is the
    contract — a third nested <code>parallel</code> is killed with its
    parent, so it cannot shut down <em>its</em> children.
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

  <h2><code>chunk</code> — how many elements ride one message</h2>
  <p>
    By default every element crosses to a worker on its own. That round
    trip costs about <strong>5µs</strong>, which is more than most
    callbacks cost, and it is the whole reason a cheap worker is
    <em>slower</em> under <code>parallel</code> than in a plain loop.
    <code>chunk: k</code> pays it once per <code>k</code> elements:
  </p>
  <pre><code>// 20,000 elements, ~0.4µs of work each, 4 workers:
await fx(rows).parallel(4, parseRow).toList();             // ~142ms
await fx(rows).parallel(4, parseRow, chunk: 512).toList(); //   ~3ms

// the same work in a plain loop, no isolates:            //   ~8ms</code></pre>
  <p>
    47× on that shape, and the batched form is the first one that
    actually beats the loop it replaced. Size <code>k</code> so that
    <code>k × callback</code> is comfortably more than 5µs, while still
    leaving several batches per worker to balance across —
    <code>length ~/ (workers * 4)</code> is a fine starting point.
  </p>
  <p>
    A batch does not change what you observe: order is the same,
    back-pressure is the same, and a worker that throws still emits the
    results of the elements <em>before</em> it and then raises on the
    element that actually failed. Two things do change. The first element
    now waits for its whole batch, so a <code>take(1)</code> wants a
    small <code>chunk</code> or none. And an unsendable <em>input</em> or
    <em>result</em>
    fails its whole batch rather than only its own pull — finding which
    element was at fault would mean sending them separately, which is the
    cost the batch exists to avoid.
  </p>

  <div class="callout">
    <strong>Related:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, any closure ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — the combined I/O form ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU ·
    <code>mapParallel</code> — the same operator as <code>parallel</code> ·
    <a href="../parallel-benchmark.html">is parallel worth it?</a> — the same job five ways, measured
  </div>
