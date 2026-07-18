---
slug: createSeededRandom
title: createSeededRandom — FxDart 101
description: FxDart createSeededRandom tutorial: a deterministic seeded PRNG for reproducible shuffles and tests, with a live playground.
heading: <code>createSeededRandom</code>
section: 12
crumb: createSeededRandom
prev: shuffle.html
prevLabel: shuffle
---
  <p class="hero-sub">A deterministic seeded random generator — the engine behind reproducible shuffles.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>createSeededRandom(seed)</code> returns a zero-argument function
    that produces pseudo-random doubles in <code>[0, 1)</code>. The sequence
    is fully determined by the seed: two generators built from the same seed
    yield exactly the same numbers, in the same order, on every platform.
  </p>
  <p>
    It's a port of FxTS's internal <code>seededRandom</code> (a
    Mulberry32-style PRNG) — in FxTS it's private, but FxDart exposes it
    because deterministic randomness is broadly useful: reproducible tests,
    stable demo data, property-based fuzzing with replayable failures, or any
    place where "random, but the same every run" is what you actually want.
    This is what <a href="shuffle.html"><code>shuffle</code></a> uses under
    the hood when you pass it a seed.
  </p>
  <p>
    Unlike <code>dart:math</code>'s <code>Random(seed)</code>, the sequence
    is part of the library's contract with FxTS — a seeded
    <code>shuffle</code> in FxDart and FxTS produces the same order for the
    same seed.
  </p>

  <h2>Demo 1 · Same seed, same sequence</h2>
  {{playground:0}}

  <h2>Demo 2 · Reproducible picks and shuffles</h2>
  <p>
    Turn the generator into whatever random shape you need — here, dice
    rolls and a seeded <code>shuffle</code>:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: deal two identical "random" hands by building both from the
    same seed.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="shuffle.html"><code>shuffle</code></a> — seeded shuffling built on this generator ·
    <a href="cycle.html"><code>cycle</code></a> &amp; <a href="repeat.html"><code>repeat</code></a> — deterministic infinite sources
  </div>
