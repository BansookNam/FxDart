---
slug: unless
title: unless — FxDart 101
description: FxDart unless tutorial: apply a transform only when a predicate fails, with a live playground.
heading: <code>unless</code>
section: 10
crumb: unless
prev: when.html
prevLabel: when
next: throwError.html
nextLabel: throwError
---
  <p class="hero-sub">Applies a callback when a predicate fails, otherwise returns the value unchanged.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>unless</code> is <a href="when.html"><code>when</code></a> with the
    condition flipped: <code>unless(predicate, callback, value)</code> runs
    <code>callback(value)</code> when <code>predicate(value)</code> is
    <strong>false</strong>, and returns <code>value</code> untouched when the
    predicate holds. It reads well for "fill in a default unless this
    condition is already satisfied" — validation, backfilling missing data,
    normalizing edge cases.
  </p>
  <p>
    Like <code>when</code>, both branches must return the same type
    <code>T</code> in Dart (no union return types), and there's no chain
    form — it's a plain data-first function.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Backfilling missing data</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>unless</code> to fill in <code>'general'</code> for
    any tag that hasn't been set.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="when.html"><code>when</code></a> — the inverse-condition sibling of unless ·
    <a href="cases.html"><code>cases</code></a> — multiple predicates instead of just one ·
    <a href="throwIf.html"><code>throwIf</code></a> — throw instead of substituting a value ·
    <a href="compact.html"><code>compact</code></a> — drop missing values instead of filling them in
  </div>
