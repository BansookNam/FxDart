---
slug: zip3
title: zip3 — FxDart 101
description: FxDart zip3 tutorial: the three-iterable form of zip, yielding (A, B, C) records and stopping at the shortest input, with a live playground.
heading: <code>zip3</code>
section: 6
crumb: zip3
prev: zip.html
prevLabel: zip
next: zipWith.html
nextLabel: zipWith
---
  <p class="hero-sub">Three iterables walked side by side — <a href="zip.html"><code>zip</code></a> with one more input.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>zip3</code> is <a href="zip.html"><code>zip</code></a> with a third
    iterable. Everything the <a href="zip.html"><code>zip</code></a> page
    explains holds unchanged — one record per step, laziness, and stopping
    the moment <em>any</em> input runs out, so the result is as long as the
    shortest of the three. The element type is a Dart record
    <code>(A, B, C)</code>, so destructure it by pattern matching rather than
    by index.
  </p>
  <p>
    It exists as its own function because Dart has no variadic generics: a
    single <code>zip</code> taking a list of iterables would have to erase
    the per-input types, and <code>(A, B, C)</code> is exactly what makes the
    result worth having. The same reason <a href="tee.html"><code>tee</code></a>
    is joined by <code>tee3</code>.
  </p>
  <p>
    One asymmetry to know: <code>zip</code> has a chain method
    (<code>fx(a).zip(b)</code>) and <code>zip3</code> does not — a chain has
    one receiver and <code>zip3</code> needs three peers. Call it as a
    top-level function and wrap the result in <code>fx()</code> to carry on,
    as the demo's last line does. <code>zip3Async</code> is the async form,
    and like <code>zipAsync</code> it issues all three <code>next()</code>
    calls before awaiting any of them, so the sources are pulled in parallel
    per record rather than one after another.
  </p>

  <h2>Demo · Three inputs, one record per step</h2>
  {{playground:0}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="zip.html"><code>zip</code></a> — the two-iterable form, and the full explanation ·
    <a href="zipWith.html"><code>zipWith</code></a> — combine instead of pairing ·
    <a href="transpose.html"><code>transpose</code></a> — any number of iterables, at the cost of a shared element type
  </div>
