---
slug: cycle
title: cycle — FxDart 101
description: FxDart cycle tutorial: repeat a sequence forever — an infinite source that must always be paired with take.
heading: <code>cycle</code>
section: 2
crumb: cycle
prev: repeat.html
prevLabel: repeat
next: entries.html
nextLabel: entries
---
  <p class="hero-sub">Yields a sequence, then repeats it — forever. Always pair it with a bound like take.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>cycle</code> is <strong>infinite</strong>: it plays the source
    sequence once, buffering its values as it goes, then loops over that
    buffer forever. Unlike everything else in this section,
    <code>cycle</code> never runs out on its own — you must always pair it
    with something that decides when to stop, almost always
    <code>.take(n)</code>. Calling <code>toArray()</code> or
    <code>consume()</code> directly on a bare <code>cycle(...)</code>
    without a bound in between will hang.
  </p>
  <p>
    One edge case worth knowing: cycling an <em>empty</em> source yields
    nothing at all, rather than looping forever over zero elements — so
    <code>cycle([])</code> is safe and simply produces an empty result.
  </p>
  <p>
    It's a natural building block for round-robin assignment (cycle through
    a small list of workers/colors/slots as you map over a longer one) or
    for repeating a short async sequence to model a polling loop. The async
    form, <code>cycleAsync</code> (or <code>.cycle()</code> on an
    <code>FxAsync</code> chain), buffers and loops the same way, but pulls
    each round through the usual async protocol.
  </p>

  <h2>Demo 1 · Infinite, bounded by take</h2>
  {{playground:0}}

  <h2>Demo 2 · Async cycle, still bounded by take</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: cycle through traffic-light colors and take the first 8.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="range.html"><code>range</code></a> — a finite counting sequence ·
    <a href="repeat.html"><code>repeat</code></a> — repeat a single value, a fixed number of times ·
    <a href="take.html"><code>take</code></a> — the bound cycle almost always needs ·
    <a href="concurrent.html"><code>concurrent</code></a> — overlap an async cycle's work
  </div>
