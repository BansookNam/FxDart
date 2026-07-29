---
slug: accumulate
title: Error accumulation — FxDart 101
description: FxDart accumulation tutorial: zipOrAccumulate, accumulate with accumulating branches, mapOrAccumulate, bindNel and toEitherNel — collect every failure, not just the first.
heading: accumulation — <code>zipOrAccumulate</code> &amp; friends
section: 13
crumb: accumulation
prev: nonEmptyList.html
prevLabel: NonEmptyList
next: eitherPipelines.html
nextLabel: Either × pipelines
---
  <p class="hero-sub">
    Validation wants <em>all</em> the errors, not the first one. These
    operations run every branch and concatenate the failures into a
    <code>NonEmptyList</code> — Arrow 2.x's replacement for a separate
    <code>Validated</code> type.
  </p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Inside <code>either&lt;Nel&lt;E&gt;, _&gt;(...)</code> — any scope whose
    error type is a <code>NonEmptyList</code> — the scope gains the
    accumulation vocabulary:
  </p>
  <ul>
    <li><code>r.zipOrAccumulate2..5(branches…, combine)</code> — run N
      independent branches, report every failure, combine the successes.</li>
    <li><code>r.accumulate((acc) { … })</code> — the general form:
      run branches with <code>acc.accumulating(block)</code>, then read each
      result's <code>.value</code>. If anything failed, reading a value (or
      reaching the end of the block) raises the <em>full</em> error list.</li>
    <li><code>r.mapOrAccumulate(items, transform)</code> — validate a whole
      collection fail-slow.</li>
    <li><code>r.bindNel(eitherNel)</code> — unwrap an
      <code>EitherNel</code>, raising all of its errors at once;
      <code>someEither.toEitherNel()</code> bridges a fail-fast value in.</li>
  </ul>
  <p>
    The contract is Arrow's: every branch runs (errors concatenate in branch
    order), a branch that <em>throws</em> instead of raising wins over
    accumulation, and after the first error successful results are no longer
    retained — iteration continues only to collect the remaining errors.
  </p>

  <h2>Demo 1 · zipOrAccumulate2</h2>
  {{playground:0}}

  <h2>Demo 2 · accumulate — the general form</h2>
  {{playground:1}}

  <h2>Demo 3 · mapOrAccumulate, bindNel &amp; toEitherNel</h2>
  {{playground:2}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: finish both branches of <code>signup</code> so the second call
    reports <em>both</em> failures.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="nonEmptyList.html"><code>NonEmptyList</code></a> — the error carrier ·
    <a href="eitherPipelines.html">Either × pipelines</a> — fail-slow validation over <code>fx()</code> chains, with concurrency ·
    <a href="raise.html"><code>either</code> &amp; Raise</a> — the fail-fast scope this extends ·
    <a href="typedErrors.html">typed errors — full guide</a>
  </div>
