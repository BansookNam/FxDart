---
slug: raise
title: either builder &amp; the Raise scope — FxDart 101
description: FxDart raise tutorial: the either and eitherAsync builders, and the Raise scope vocabulary — bind, ensure, ensureNotNull, recover, withError, raise.
heading: <code>either</code> &amp; the <code>Raise</code> scope
section: 13
crumb: either &amp; Raise
prev: eitherCombinators.html
prevLabel: Either combinators
next: nullable.html
nextLabel: nullable
---
  <p class="hero-sub">
    Runs a block in a <code>Raise&lt;E&gt;</code> scope: straight-line code
    that can short-circuit with a typed error. A raised <code>E</code> becomes
    <code>Left</code>, a normal return becomes <code>Right</code>.
  </p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The builder hands your block a scope <code>r</code> — the port of Kotlin
    Arrow's <code>either&nbsp;{&nbsp;}</code>. Everything hangs off it; type
    <code>r.</code> and discover the whole vocabulary:
  </p>
  <ul>
    <li><code>r.bind(either)</code> / <code>r.bindAll(eithers)</code> —
      unwrap a success or short-circuit with the failure.</li>
    <li><code>r.ensure(cond, () => err)</code> — the typed-error
      <code>require</code>.</li>
    <li><code>r.ensureNotNull(x, () => err)</code> — returns non-null, with
      type promotion.</li>
    <li><code>r.recover(block, onRaise)</code> — handle a raised error in a
      nested scope and keep going.</li>
    <li><code>r.withError(transform, block)</code> — adapt a
      <em>different</em> error type into this scope.</li>
    <li><code>r.raise(err)</code> — short-circuit directly; returns
      <code>Never</code>, so flow analysis knows execution stops.</li>
  </ul>
  <p>
    Internally this is <em>not</em> <code>flatMap</code> chaining: a failed
    <code>bind</code> throws a private, scope-tagged signal that the builder
    catches at its boundary. That is why early returns, loops and
    <code>if</code>s all just work inside the block, and why nested builders
    never capture each other's errors. <code>eitherAsync</code> is the async
    twin — same vocabulary, <code>await</code> allowed (raise only within the
    same awaited chain).
  </p>

  <h2>Demo 1 · ensure &amp; ensureNotNull</h2>
  {{playground:0}}

  <h2>Demo 2 · bind — the flatMap-pyramid killer</h2>
  {{playground:1}}

  <h2>Demo 3 · recover, withError &amp; raise</h2>
  {{playground:2}}

  <h2>Demo 4 · eitherCatching — the exception boundary, pre-combined</h2>
  <p>
    Real parsing fails two ways at once: your rules <em>raise</em> typed
    errors, while the platform (<code>int.parse</code>, <code>jsonDecode</code>)
    <em>throws</em>. <code>eitherCatching</code> is <code>either</code> +
    <code>catching</code> as one builder — the block may raise or throw,
    and the second argument maps anything thrown into the same typed error.
    The raise signal itself is never handed to it. <code>recover</code>
    accepts the same optional <code>onThrow:</code> clause, completing
    Arrow&nbsp;2.x's three-clause <code>recover(block, recover, catch)</code>.
  </p>
  {{playground:4}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: make <code>checkAge</code> fail with a typed error instead of
    throwing — <code>ensureNotNull</code> for the parse,
    <code>ensure</code> for the age limit.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>Two rules.</strong> (1) Never return a <em>lazy</em> pipeline
    from a raise block — materialize with <code>toList()</code> inside it, or
    use the <a href="eitherPipelines.html">eager Either terminals</a>; a
    deferred raise fails loudly with <code>RaiseLeakedError</code>. (2) Never
    bare-<code>catch</code> inside a raise block — use
    <code>catching</code>/<code>catchingAsync</code>, which always let the
    short-circuit signal through.
  </div>

  <div class="callout">
    <strong>Related:</strong>
    <a href="either.html"><code>Either</code></a> — the boundary type ·
    <a href="nullable.html"><code>nullable</code></a> — the info-free twin that returns <code>T?</code> ·
    <a href="accumulate.html">accumulation</a> — collect every failure ·
    <a href="typedErrors.html">typed errors — full guide</a>
  </div>
