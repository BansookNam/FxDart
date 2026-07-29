---
slug: either
title: Either — FxDart 101
description: FxDart Either tutorial: the sealed result type with Left and Right, exhaustive switch, fold, map, flatMap, and capturing thrown exceptions with Either.catching.
heading: <code>Either</code>
section: 13
crumb: Either
prev: typedErrors.html
prevLabel: typed errors
next: raise.html
nextLabel: either &amp; Raise
---
  <p class="hero-sub">
    A value that is either a failure <code>Left(L)</code> or a success
    <code>Right(R)</code> — the boundary type of the typed-error system.
  </p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>Either&lt;L, R&gt;</code> makes failure part of a function's
    <em>signature</em>: instead of throwing (invisible to the type system) or
    returning <code>null</code> (says nothing about <em>why</em>), you return
    <code>Left(error)</code> or <code>Right(value)</code>. The class is
    <code>sealed</code>, so a <code>switch</code> over it is exhaustive — the
    compiler reminds you to handle the failure case.
  </p>
  <p>
    The method set is Arrow 2.x's curated one: <code>fold</code> collapses
    both sides into one value, <code>map</code>/<code>mapLeft</code> transform
    one side, <code>flatMap</code> chains a dependent fallible step, and
    <code>getOrNull</code>/<code>getOrElse</code> bridge back to plain Dart.
    <code>Either</code> is meant to live <em>at the boundary</em>: inside a
    computation, prefer the <a href="raise.html"><code>either</code>
    builder</a>, where each step is one straight-line <code>r.bind</code>
    instead of a <code>flatMap</code> pyramid.
  </p>

  <h2>Demo 1 · Left, Right, and exhaustive switch</h2>
  {{playground:0}}

  <h2>Demo 2 · fold, map, mapLeft, flatMap</h2>
  {{playground:1}}

  <h2>Demo 3 · dot shorthands (Dart ≥ 3.10)</h2>
  <p>
    <code>Either</code> carries <code>const</code> factories
    <code>Either.left</code> / <code>Either.right</code> so Dart 3.10
    <em>dot shorthands</em> resolve against it: wherever the context type is
    already <code>Either</code> — a return position, a switch-expression arm,
    the right side of <code>==</code> — you can drop the type name and write
    <code>.left(error)</code> / <code>.right(value)</code>. Same objects as
    <code>Left(…)</code> / <code>Right(…)</code>, just inferred from context.
  </p>
  {{playground:3}}

  <h2>Try it yourself</h2>
  <p>
    Exceptions and typed errors stay strictly separated: a <em>thrown</em>
    exception propagates out of typed-error code untouched. To capture a
    throw into an <code>Either</code>, be explicit with
    <code>Either.catching</code> (failure type <code>Object</code>) or
    <code>Either.catchingWith</code> (map the throw to your own failure type
    first). Exercise: make the failing parse print
    <code>Left(bad input)</code> instead of crashing.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="raise.html"><code>either</code> builder</a> — build Eithers with straight-line code ·
    <a href="accumulate.html">accumulation</a> — collect every failure, not just the first ·
    <a href="eitherPipelines.html">Either × pipelines</a> — <code>rights</code>, <code>lefts</code>, <code>sequence</code> over chains ·
    <a href="typedErrors.html">typed errors — full guide</a>
  </div>
