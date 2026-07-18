---
slug: index
title: FxDart — Functional programming for Dart
description: FxDart is a functional programming library for Dart, ported from FxTS: lazy evaluation, concurrent async iteration, and pipeline-style composition.
---
  <p class="hero-logo"><img src="assets/logo-web.png" width="960" height="294"
      alt="FxDart"></p>
  <h1>Functional programming for Dart,<br>with laziness and concurrency built in.</h1>
  <p class="hero-sub">
    FxDart is a Dart port of <a href="https://github.com/marpple/FxTS">FxTS</a> —
    a library for composing <strong>lazy pipelines</strong> over sync and async data,
    where turning six sequential 1-second requests into a 2-second concurrent batch
    is one method call.
  </p>

  {{playground:0}}
  <p class="dim">▲ This is live — edit the code and press <strong>Run</strong>.
    It compiles with the real Dart compiler and executes in your browser.</p>

  <h2>What is FxDart?</h2>
  <p>
    FxDart brings the FxTS programming model to Dart: a toolkit of ~120 small,
    composable functions for transforming collections and asynchronous data.
    Three ideas define it:
  </p>
  <ul>
    <li><strong>Lazy evaluation</strong> — operators like <code>map</code>,
      <code>filter</code>, and <code>take</code> build a pipeline but do no work
      until a terminal operator (<code>toArray</code>, <code>each</code>,
      <code>reduce</code>…) pulls values through it. Processing a million-element
      range with <code>.take(3)</code> computes exactly 3 results.</li>
    <li><strong>One model for sync and async</strong> — the same operator names
      work on plain <code>Iterable</code>s and on <code>FxAsyncIterable</code>,
      FxDart's pull-based async sequence (with <code>Stream</code> bridges both
      ways).</li>
    <li><strong>Declarative concurrency</strong> — <code>concurrent(n)</code>
      asks the <em>upstream</em> pipeline to evaluate <code>n</code> items at a
      time while keeping results in order. It is FxTS's signature feature,
      ported faithfully to Dart.</li>
  </ul>

  <h2>Why do we need it?</h2>
  <p>
    Dart already has <code>Iterable</code> and <code>Stream</code>. FxDart earns
    its place where those run out:
  </p>
  <table>
    <tr><th>Problem</th><th>Plain Dart</th><th>FxDart</th></tr>
    <tr>
      <td>Limit concurrent API calls to <em>n</em>, keep order</td>
      <td>Manual queues, <code>Completer</code>s, careful bookkeeping</td>
      <td><code>.map(fetch).concurrent(3)</code></td>
    </tr>
    <tr>
      <td>Async transform pipelines</td>
      <td><code>Stream</code> is push-based; mixing <code>await</code>, backpressure and laziness gets intricate</td>
      <td>Pull-based chain — each value is computed only when asked for</td>
    </tr>
    <tr>
      <td>Data wrangling (group, index, count, partition, zip, chunk…)</td>
      <td>Hand-rolled loops each time</td>
      <td>One well-tested named function per concept</td>
    </tr>
    <tr>
      <td>Readable multi-step transforms</td>
      <td>Nested calls or intermediate variables</td>
      <td>Left-to-right <code>fx()</code> chains, fully typed</td>
    </tr>
  </table>

  <h2>Pros &amp; Cons</h2>
  <div class="proscons">
    <div class="box pros">
      <h3>✓ Pros</h3>
      <ul>
        <li><strong>Laziness for free</strong> — pipelines short-circuit; only requested values are computed.</li>
        <li><strong>Order-preserving concurrency</strong> with a single operator: <code>concurrent(n)</code> / completion-order <code>concurrentPool(n)</code>.</li>
        <li><strong>Fully typed chains</strong> — <code>fx()</code> keeps inference end-to-end; sync operators are plain functions over native <code>Iterable</code>s, so everything interops with ordinary Dart.</li>
        <li><strong>Small, focused functions</strong> — ~120 operators covering transform / filter / slice / combine / aggregate / object / util.</li>
        <li><strong>Battle-tested semantics</strong> — behavior ported from FxTS along with 850+ of its tests.</li>
        <li><strong>Zero dependencies</strong> — pure Dart.</li>
      </ul>
    </div>
    <div class="box cons">
      <h3>✗ Cons</h3>
      <ul>
        <li><strong>No data-last currying</strong> — Dart lacks function overloads, so FxTS's curried <code>pipe</code> style becomes chains; the dynamic <code>pipe()</code> loses static types.</li>
        <li><strong>A second async abstraction</strong> — <code>FxAsyncIterable</code> exists because <code>Stream</code> can't express the concurrency back-channel; bridging is easy but it is one more concept to learn.</li>
        <li><strong>Learning curve</strong> — thinking in lazy pipelines differs from imperative loops.</li>
        <li><strong>Not always fastest</strong> — for tiny hot loops, a hand-written <code>for</code> can beat operator composition; FxDart optimizes for clarity and I/O-bound work.</li>
        <li><strong>Some TS APIs don't port literally</strong> — they get Dart-native spellings instead: <code>curry</code> becomes the typed <a href="tutorials/curried.html"><code>.curried</code></a> extension getter, with the old names kept as deprecated stubs for migration.</li>
      </ul>
    </div>
  </div>

  <h2>Taste of concurrency</h2>
  <p>Six fake requests of 300&nbsp;ms each — sequentially ~1.8&nbsp;s, with
    <code>concurrent(3)</code> about 0.6&nbsp;s. Try changing the number:</p>
  {{playground:1}}

  <h2>Start learning</h2>
  <div class="grid">
    <a class="card" href="101/index.html">
      <h3>FxDart 101 →</h3>
      <p>A guided course: lectures, live demos, and a playground for every function.</p>
    </a>
    <a class="card" href="tutorials/map.html">
      <h3>First lesson: map →</h3>
      <p>Start with the most fundamental operator.</p>
    </a>
    <a class="card" href="https://github.com/bansooknam/fxDart">
      <h3>Install →</h3>
      <p>Get fxdart into your pubspec and browse the source.</p>
    </a>
  </div>
