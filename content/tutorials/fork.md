---
slug: fork
title: fork — FxDart 101
description: FxDart fork tutorial: branch one buffered iteration of a source into multiple independent readers, with a live playground.
heading: <code>fork</code>
section: 6
crumb: fork
prev: reverse.html
prevLabel: reverse
next: reduce.html
nextLabel: reduce
---
  <p class="hero-sub">Branches one buffered iteration of a source into independent, replayable readers.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Iterating the same Dart <code>Iterable</code> object twice normally runs
    its source twice — a <code>sync*</code> generator restarts from scratch
    every time you ask for a fresh <code>.iterator</code>. That's wasteful
    (or outright wrong) when producing a value is expensive: a network
    fetch, a slow computation, a stream you can only read once.
    <code>fork</code> fixes this: every call to <code>fork(iterable)</code>
    with the <em>same</em> <code>iterable</code> object returns an
    independent cursor over one shared, lazily-growing buffer. The
    underlying source is walked exactly once, no matter how many forks read
    from it or in what order.
  </p>
  <p>
    The sharing is keyed by the identity of the <code>iterable</code> you
    pass in (via an internal <code>Expando</code>), so you must fork the
    <em>same object</em> — not two separately-constructed iterables that
    happen to look alike. Each fork can be consumed at its own pace: reading
    ahead on one fork pulls new values from the source and appends them to
    the shared buffer; a fork that's behind just replays values already in
    the buffer, at no extra cost. <code>forkAsync</code> works the same way
    for <code>FxAsyncIterable</code>, and additionally lets concurrent
    downstream demand from multiple forks pull the shared async source in
    parallel.
  </p>

  <h2>Demo 1 · One source, two branches, proven with a counter</h2>
  <p>
    <code>source()</code> increments <code>calls</code> every time it
    produces a value. Both <code>evens</code> and <code>doubled</code> fork
    the exact same <code>shared</code> object — if the source ran twice,
    <code>calls</code> would end up at 10, not 5:
  </p>
  {{playground:0}}

  <h2>Demo 2 · Forks at different paces share one buffer</h2>
  <p>
    Branch <code>a</code> races ahead and pulls two fresh values; when
    branch <code>b</code> asks for its first two, it simply replays what
    <code>a</code> already buffered — no new calls to <code>source()</code>
    until <code>b</code> needs a third value neither fork has seen yet:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: right now <code>readings</code> is iterated twice with no
    <code>fork</code>, so <code>sensor()</code> runs twice and
    <code>reads</code> ends up at 6. Fork <code>readings</code> for each
    consumer so the sensor is only read once (<code>reads</code> should be
    3).
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="peek.html"><code>peek</code></a> — observe without branching ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation within one branch ·
    <a href="memoize.html"><code>memoize</code></a> — cache a single value instead of a whole sequence
  </div>
