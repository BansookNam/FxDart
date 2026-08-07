---
slug: eitherCombinators
title: Either combinators — FxDart 101
description: FxDart Either combinators tutorial: map2 through map5, alt, orElse and filterOrElse, with a live playground.
heading: <code>Either</code> combinators
section: 13
crumb: Either combinators
prev: either.html
prevLabel: Either
next: raise.html
nextLabel: either &amp; Raise
---
  <p class="hero-sub">Combining, falling back, and validating — <code>map2</code>…<code>map5</code>, <code>alt</code>, <code>orElse</code>, <code>filterOrElse</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <a href="either.html"><code>Either</code></a> on its own gives you
    <code>map</code>, <code>flatMap</code> and <code>fold</code>. These four
    methods cover the shapes that kept turning into a <code>flatMap</code>
    with an <code>if</code> inside it.
  </p>

  <h3><code>map2</code> … <code>map5</code> — combining independent results</h3>
  <p>
    When several <code>Either</code>s have to succeed together —
    parse a name <em>and</em> an age <em>and</em> an email —
    <code>map2</code> combines them and keeps the <strong>leftmost</strong>
    failure. The combining callback runs only when every branch is a
    <code>Right</code>. Arities run to five, the same cap as
    <a href="accumulate.html"><code>zipOrAccumulate2..5</code></a> and
    <code>Curry2..Curry5</code>.
  </p>
  <p>
    "Fail-fast" here is about the <em>reporting</em>, not the work. The
    branches are values you already computed, so all of them ran; what stops
    at the first failure is the answer you get back. When you want every
    failure — a form that highlights all four bad fields at once — that is
    <a href="accumulate.html">accumulation</a>, which reports an
    <code>EitherNel</code> instead and needs an <code>accumulate</code> scope.
    Reach for <code>map2</code> when one message is the right answer.
  </p>

  <h3><code>alt</code> and <code>orElse</code> — falling back</h3>
  <p>
    <code>alt</code> is the fallback ladder: try this, and if it failed try
    that. The alternative is a callback, so nothing beyond the first hit is
    touched — cache, then disk, then network, paying only for what you
    actually reach. The failure is discarded.
  </p>
  <p>
    <code>orElse</code> is the same move for when the failure matters: the
    handler receives it and may return a different failure type, so it is also
    how you translate one error vocabulary into another.
  </p>
  <p>
    <a href="raise.html"><code>recover</code></a> is the richer sibling. It
    runs the handler inside a fresh raise scope, so the handler writes
    straight-line Dart and calls <code>r.raise</code> instead of constructing
    an <code>Either</code> by hand. Use <code>alt</code>/<code>orElse</code>
    when the replacement <code>Either</code> already exists, and
    <code>recover</code> when the handler has real work to do.
  </p>

  <h3><code>filterOrElse</code> — validating in place</h3>
  <p>
    Demotes a <code>Right</code> whose value fails a predicate into a
    <code>Left</code> that the second callback builds <em>from that value</em>
    — so the message can name what was wrong. A <code>Left</code> passes
    through untouched and the predicate never runs. Chain them and the first
    failing check wins.
  </p>
  <p>
    It is the <code>Either</code>-value form of
    <a href="raise.html"><code>Raise.ensure</code></a>, which does the same
    job inside an <code>either { }</code> builder. Inside a builder, prefer
    <code>ensure</code>; on a value you already hold, this.
  </p>

  <h2>Demo 1 · map2 and map3</h2>
  {{playground:0}}

  <h2>Demo 2 · alt, orElse, filterOrElse</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: reject an age outside 0..149, with a message of your own.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="either.html"><code>Either</code></a> — the type these extend ·
    <a href="raise.html"><code>either</code> &amp; <code>Raise</code></a> — builder scope, <code>ensure</code> and <code>recover</code> ·
    <a href="accumulate.html">accumulation</a> — every failure instead of the first ·
    <a href="eitherPipelines.html">Either × pipelines</a> — carrying Eithers through a chain
  </div>
