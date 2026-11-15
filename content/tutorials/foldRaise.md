---
slug: foldRaise
title: foldRaise — FxDart 101
description: FxDart foldRaise tutorial: the primitive under fxEither and fxNullable — run a Raise block and fold its three outcomes, value, raised error or thrown exception.
heading: <code>fxFoldRaise</code>
section: 13
crumb: foldRaise
prev: raise.html
prevLabel: either &amp; Raise
next: nullable.html
nextLabel: nullable
---
  <p class="hero-sub">
    Runs a block in a fresh <code>Raise&lt;E&gt;</code> scope and folds
    whatever happens — a value, a raised error, or a thrown exception —
    into one result type.
  </p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="raise.html">fxEither</a></code> turns a raise block into
    an <code>Either</code>; <code><a href="nullable.html">fxNullable</a></code>
    turns one into a <code>T?</code>. Both are one call to
    <code>fxFoldRaise</code>, the single primitive every builder derives from
    — the port of Arrow's <code>fold</code>. It runs <code>block</code> with
    a new scope <code>r</code> and dispatches on how the block ended:
  </p>
  <ul>
    <li>a normal return → <code>onValue(value)</code>;</li>
    <li><code>r.raise(e)</code> from <em>this</em> scope →
      <code>onRaise(e)</code>;</li>
    <li>a thrown exception → <code>onThrow(thrown, stackTrace)</code> if
      you gave one, otherwise it is rethrown;</li>
    <li>a raise from a <em>different</em> scope → rethrown untouched, so it
      lands at the builder it belongs to. That is what makes nested scopes
      correct with no dynamic scoping.</li>
  </ul>
  <p>
    Reach for it when neither an <code>Either</code> nor a <code>T?</code> is
    the shape you want at the boundary — a status string, an HTTP response,
    a record, a sealed type of your own — and you would otherwise build an
    <code>Either</code> only to <code>switch</code> on it on the next line.
    It is also how you write a builder of your own: <code>fxEither</code> is
    <code>fxFoldRaise</code> with an <code>onRaise</code> that builds a
    <code>Left</code> and an <code>onValue</code> that builds a
    <code>Right</code>, and nothing else. <code>onThrow</code> is the three-clause
    form that <code>fxEitherCatching</code> and <code>r.recover</code> pass
    through; the raise signal itself is never handed to it.
  </p>
  <p>
    <code>fxFoldRaiseAsync</code> is the async twin: the block and every
    handler may await, and the same rule as <code>fxEitherAsync</code>
    applies — raise only within the awaited chain. The scope is closed when
    the fold returns, so a lazy pipeline that would raise later must be
    materialized inside the block. Named <code>fxFoldRaise</code> because
    <code><a href="fold.html">fxFold</a></code> already exists.
  </p>

  <h2>Demo 1 · Three outcomes, one result type</h2>
  {{playground:0}}

  <h2>Demo 2 · A builder of your own, nesting &amp; async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: skip the intermediate <code>Either</code> and fold the scope
    straight into the message.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="raise.html"><code>fxEither</code> &amp; the <code>Raise</code> scope</a> — the builder built on it ·
    <a href="nullable.html"><code>fxNullable</code></a> — the info-free builder, also one fold ·
    <a href="either.html"><code>Either</code></a> — <code>fold</code> on a value you already have ·
    <a href="typedErrors.html">typed errors — full guide</a>
  </div>
