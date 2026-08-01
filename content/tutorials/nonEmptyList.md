---
slug: nonEmptyList
title: NonEmptyList (Nel) — FxDart 101
description: FxDart NonEmptyList tutorial: a zero-cost extension type for lists that cannot be empty — head and first are total, and it carries accumulated errors.
heading: <code>NonEmptyList</code> · <code>Nel</code>
section: 13
crumb: NonEmptyList
prev: nullable.html
prevLabel: nullable
next: accumulate.html
nextLabel: accumulation
---
  <p class="hero-sub">
    A list statically guaranteed to hold at least one element — the error
    carrier of the accumulation API. Zero-cost: an extension type, erased at
    runtime.
  </p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    "A list of validation errors" has an awkward edge case: what does an
    <em>empty</em> error list mean? <code>NonEmptyList</code> (alias
    <code>Nel</code>) removes the question in the type system — if you hold
    one, there is at least one element, so <code>head</code> is total and
    cannot throw, unlike <code>List.first</code>. That's exactly what
    <a href="accumulate.html">accumulation</a> needs:
    <code>EitherNel&lt;E, A&gt;</code> = <code>Either&lt;Nel&lt;E&gt;, A&gt;</code>,
    where a <code>Left</code> always carries at least one error.
  </p>
  <p>
    It is Dart's analogue of Arrow's <code>value class NonEmptyList</code>:
    an <em>extension type</em> over <code>List</code> — zero allocation,
    erased at runtime, and it <code>implements Iterable</code>, so every
    fxdart pipeline and <code>for</code> loop takes it directly. The
    invariant is compile-time discipline: build one only through
    <code>NonEmptyList.of(head, [tail])</code> or
    <code>NonEmptyList.orNull(list)</code> (which returns <code>null</code>
    for an empty list — the emptiness check happens exactly once, at the
    boundary). A cast like <code>list as Nel&lt;int&gt;</code> would bypass
    the check at your own risk.
  </p>

  <h2>Demo 1 · of, orNull, head &amp; tail</h2>
  {{playground:0}}

  <h2>Demo 2 · map, +, and pipelines</h2>
  {{playground:1}}

  <h2>Demo 3 · toNelOrNull — any Iterable in</h2>
  <p>
    <code>Nel.orNull</code> takes a <code>List</code>, so every
    accumulating pipeline used to end in a <code>.toList()</code> shuffle
    before its errors could become a panel. The
    <code>toNelOrNull()</code> extension (Arrow's
    <code>toNonEmptyListOrNull</code>) accepts any <code>Iterable</code> —
    including a lazy <code>fx</code> chain — copies it, and gives you the
    <code>Nel?</code> directly: <code>null</code> for "no errors", a
    guaranteed-non-empty list otherwise.
  </p>
  {{playground:3}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: finish <code>summarize</code> — with the <code>null</code> case
    already handled, <code>nel.length</code> and <code>nel.head</code> can't
    fail.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="accumulate.html">accumulation</a> — where <code>Nel</code> carries every failure ·
    <a href="either.html"><code>Either</code></a> — <code>toEitherNel()</code> lifts a failure into a singleton <code>Nel</code> ·
    <a href="head.html"><code>firstOrNull</code></a> — the nullable-first access it makes total ·
    <a href="typedErrors.html">typed errors — full guide</a>
  </div>
