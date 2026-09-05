---
slug: parallel-benchmark
title: Is parallel worth it? — FxDart
description: One CPU-bound job, five ways to run it — a plain loop, hand-rolled isolates, the fxdart chain, fxdart parallel, and parallel with a chunk — measured at three per-element costs.
heading: Is <code>parallel</code> worth it?
---
  <p class="hero-sub">One job, five ways to run it. The answer depends on
    exactly one number, and it is not the number people reach for.</p>

  <p>
    Every "use isolates for CPU work" article stops before the part that
    decides it. Handing one element to another isolate and getting the
    result back costs about <strong>5µs</strong>. If the work on that
    element costs less than that, no number of cores will save you — you
    have bought a courier to carry a letter across the room.
  </p>
  <p>
    So these three cases vary one thing: the cost of a single element.
    Everything else — the dataset, the checksum, the worker function — is
    held fixed, and every program calls the <em>same</em> top-level
    function, so the only difference between them is where that function
    runs.
  </p>

  <h2>The five ways</h2>
  <ol>
    <li><strong>Native, one isolate</strong> — a plain <code>for</code>
      loop. The baseline every other row is measured against, because it is
      what the code looked like before anyone reached for a library.</li>
    <li><strong>Native + <code>dart:isolate</code></strong> — slice the
      list, one <code>Isolate.run</code> per slice, <code>Future.wait</code>,
      concatenate. This is what you write by hand, and it is the bar
      <code>parallel</code> has to clear: it is not enough to beat the
      loop.</li>
    <li><strong>fxdart chain, one isolate</strong> —
      <code>fx(xs).map(work).toList()</code>. It shares no work with the
      isolates; it is here to price the chain itself, so the row below is
      not quietly credited with the chain's overhead or blamed for it.</li>
    <li><strong>fxdart <code>.parallel()</code></strong> — the same chain
      with one operator changed, at its default: every element crosses to a
      worker on its own. This is what you write first.</li>
    <li><strong>fxdart <code>.parallel(chunk:)</code></strong> — the same
      operator with <code>k</code> elements on each message, so the trip is
      paid once per batch instead of once per element. The last two rows are
      one row apart on purpose: the gap between them <em>is</em> the round
      trip, drawn to scale.</li>
  </ol>

  <h2>Reading the numbers</h2>
  <p>
    Each case is sized so the plain loop runs for about
    <strong>five seconds</strong>. That is deliberate: below a second,
    spawning the isolates (~1ms each) and copying the data are a large
    enough share of the total that the measurement is mostly about the
    harness. A job worth parallelising is a job that takes a while.
  </p>
  <p>
    The two smaller blocks run the identical program at N&nbsp;=&nbsp;10,000
    and N&nbsp;=&nbsp;100. They are not padding — they are the other half of
    the answer. Isolates have a fixed price: about a millisecond to spawn
    each one, plus copying the data in and the results back out. The smaller
    the job, the less is left to win, and where that crosses over is not
    guessable from the element count alone. Watch
    <code>password-rehash</code> still win at N&nbsp;=&nbsp;100 while
    <code>log-fingerprint</code> has already lost at N&nbsp;=&nbsp;10,000:
    it is total work that decides, not how many things there are.
  </p>

  <div class="callout">
    <strong>What to look for.</strong> In
    <code>password-rehash</code> each element costs ~250µs — fifty times
    the trip — and <code>parallel</code> wins with no tuning at all.
    In <code>log-fingerprint</code> each element costs ~3.5µs, <em>less</em>
    than the trip, and the default <code>parallel</code> is <em>slower than
    the plain loop</em>. That is not a defect; it is the operator being
    asked to pay a per-element price for a per-element job.
    <code>chunk:</code> is the fix, and the last two rows are how much it
    is worth.
  </div>

  <h2>Why more workers cannot fix the slow row</h2>
  <p>
    If <code>log-fingerprint</code> were merely short of parallelism, a
    bigger pool would help. It does not. The same program at
    N&nbsp;=&nbsp;100,000, varying nothing but the number of workers:
  </p>
  <pre><code>workers   .parallel()        .parallel(chunk:)
      1     768.8 ms             381.0 ms
      2     831.9 ms             191.1 ms
      5     899.1 ms              86.5 ms
     10     873.5 ms              71.0 ms</code></pre>
  <p>
    This table is a separate measurement (<code>BENCH_N=100000</code>,
    <code>BENCH_WORKERS</code> 1–10). It is not in
    <code>results-parallel.json</code>, so regenerating the page charts
    does not refresh these four rows.
  </p>
  <p>
    The default form does not improve at all — it drifts slightly
    <em>worse</em>, and its cost stays around 8µs per element whatever the
    pool size. The chunked form scales 5.4× across the same range.
  </p>
  <p>
    That is the diagnosis. At <code>chunk: 1</code> every element costs two
    message copies, a port event and a completer <strong>on the main
    isolate</strong> — which is one thread, and the one thing in the system
    that cannot be parallelised. About 8µs of coordination (the hop plus
    that completer and event) to hand off 3.5µs of work. The workers are
    not the bottleneck; they are idle, waiting to be fed by a main isolate
    that is spending all its time posting letters. Extra workers only add
    contention for it.
  </p>
  <p>
    A batch does not make the coordination cheaper — it makes there be less
    of it. The chunked row uses <code>n ~/ (workers * 4)</code>, so ten
    workers always send 40 messages. At this sweep that is
    <code>chunk: 2500</code> instead of 100,000 round trips; at the
    headline (N = 1,500,000) it is <code>chunk: 37500</code> instead of
    1.5 million trips. The main isolate stops being the bottleneck, and
    the work finally lands where it was supposed to go.
  </p>

  <p>
    Sources: <code>benchmark/cases-parallel/</code>. Regenerate with
    <code>dart run benchmark/run_parallel_benchmarks.dart</code>. The runner
    refuses a case whose variants do not all produce an identical checksum,
    so the rows are always different ways of computing one answer.
  </p>
