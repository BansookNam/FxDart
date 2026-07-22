---
slug: shuffle
title: shuffle — FxDart 101
description: FxDart shuffle tutorial: Fisher-Yates shuffle with an optional seed for reproducible order, sync and async, with a live playground.
heading: <code>shuffle</code>
section: 12
crumb: shuffle
next: createSeededRandom.html
nextLabel: createSeededRandom
---
  <p class="hero-sub">Returns a new list with elements in shuffled order — pass a seed for a reproducible result.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>shuffle</code> runs a Fisher-Yates shuffle over the elements of
    <code>iterable</code> and returns a brand-new <code>List&lt;T&gt;</code> —
    the input is never mutated. Called with no seed, it uses
    <code>dart:math</code>'s <code>Random</code>, so every call gives a
    different order, exactly as you'd expect for something like a card deck
    or a randomized quiz.
  </p>
  <p>
    Pass an <code>int</code> <code>seed</code> and shuffle switches to a
    seeded PRNG (a Dart port of the same Mulberry32-style generator FxTS
    uses), so the <em>same seed always produces the same order</em> — on any
    run, on any machine. That determinism is what makes seeded shuffling
    useful for things like reproducible test fixtures, "daily challenge"
    puzzles where everyone with today's seed sees the same layout, or
    deterministic replays of a randomized simulation.
  </p>
  <p>
    <code>shuffleAsync</code> is the <code>*Async</code> twin: it materializes
    an <code>FxAsyncIterable</code> first (via <code>toListAsync</code>
    internally) and then shuffles the result, so a seeded async shuffle
    produces the identical order to its sync counterpart given the same seed.
  </p>

  <h2>Demo 1 · Seeded determinism</h2>
  <p>Same seed, same order — every time. A different seed gives a different
    (but still reproducible) order:</p>
  {{playground:0}}

  <h2>Demo 2 · shuffleAsync matches the sync order, and nothing is lost</h2>
  <p>
    Same seed gives the identical order whether the source is sync or async
    — and every element from the input is still present, just reordered:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: give this turn order a seed so it's reproducible across app
    restarts instead of random every time.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="throttle.html"><code>throttle</code></a> — rate-limiting for callbacks ·
    <a href="debounce.html"><code>debounce</code></a> — wait-for-quiet rate limiting ·
    <a href="toAsync.html"><code>toAsync</code></a> — lifting a list for shuffleAsync ·
    <a href="sort.html"><code>sort</code></a> — the opposite instinct: deterministic order
  </div>
