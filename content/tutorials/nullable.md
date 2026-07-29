---
slug: nullable
title: nullable — FxDart 101
description: FxDart nullable tutorial: the nullable and nullableAsync builders — straight-line unwrapping of nullable values, the nullable-first alternative to an Option type.
heading: <code>nullable</code>
section: 13
crumb: nullable
prev: raise.html
prevLabel: either &amp; Raise
next: nonEmptyList.html
nextLabel: NonEmptyList
---
  <p class="hero-sub">
    Runs a block in an info-free raise scope: any short-circuit makes the
    whole block evaluate to <code>null</code>. The nullable-first alternative
    to an <code>Option</code> type.
  </p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    When the only failure information you need is <em>absence</em>, an
    <code>Either</code> is overkill — Dart already has a dedicated absence
    channel: <code>T?</code>. <code>nullable</code> is the
    <a href="raise.html"><code>either</code> builder</a>'s info-free twin
    (the port of Arrow's <code>nullable&nbsp;{&nbsp;}</code>): the scope's
    <code>r.bind(value)</code> unwraps a nullable, and if it's
    <code>null</code> the whole block returns <code>null</code>.
  </p>
  <p>
    Compared to chaining <code>?.</code> and <code>??</code>, the win is that
    <em>any</em> step can bail out — a lookup, a parse, a condition via
    <code>r.ensure(cond)</code> — without nesting, and intermediate values
    stay promoted and non-null. This is why FxDart ships no
    <code>Option</code>/<code>Maybe</code> type: <code>T?</code> plus this
    builder covers it, with zero wrapping.
  </p>

  <h2>Demo 1 · bind on tryParse</h2>
  {{playground:0}}

  <h2>Demo 2 · deep lookups without ?. staircases</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: <code>lastSeen['lee']</code> exists but holds <code>null</code>,
    and <code>'park'</code> is missing entirely — <code>r.bind</code> treats
    both as absence. Fix <code>describe</code> so both print
    <code>null</code>.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="raise.html"><code>either</code> builder</a> — when the failure needs a reason ·
    <a href="either.html"><code>Either</code></a> — <code>getOrNull()</code> bridges back to nullable ·
    <a href="compact.html"><code>nonNulls</code></a> — drop nulls from a pipeline ·
    <a href="typedErrors.html">typed errors — full guide</a>
  </div>
