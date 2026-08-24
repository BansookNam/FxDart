---
slug: mapEither
title: mapEither — FxDart 101
description: FxDart mapEither tutorial: run each event in a Raise scope so a raise becomes a Left and a return a Right, with an async twin — with a live playground.
heading: <code>mapEither</code> &amp; <code>mapEitherAsync</code>
section: 14
crumb: mapEither
prev: attempt.html
prevLabel: attempt
next: separated.html
nextLabel: separated
---
  <p class="hero-sub">Run each event in its own raise scope: <code>r.raise</code> (and <code>r.ensure</code> / <code>r.bind</code>) becomes a <code>Left</code>, a normal return a <code>Right</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="attempt.html">attempt</a></code> is the boundary
    conversion — it turns whatever is already on the error channel into
    a <code>Left</code>. <code>mapEither</code> is the operator you
    reach for <em>after</em> that, or on a clean source: each event
    runs inside an <code><a href="raise.html">either</a></code> builder,
    so you write straight-line Dart with <code>r.ensure</code> /
    <code>r.raise</code> and the result of the whole map is
    <code>Either&lt;E, R&gt;</code>. A failing event does not cancel
    the source; later events still arrive.
  </p>
  <p>
    A <em>thrown</em> exception stays on the error channel — that is the
    <code>either</code> builder's contract, and it keeps
    <code>attempt</code> the single place where a throw turns into a
    value. When a callback both raises and throws, prefer
    <code>eitherCatching</code> inside <code>mapEither</code> so one
    <code>Either</code> comes out.
  </p>
  <p>
    <code>mapEitherAsync</code> is the async twin: one event at a time,
    like <code>asyncMap</code>. <code>eitherAsync</code>'s rule carries
    over: a raise must happen inside the awaited chain. A raise from an
    unawaited future outlives the scope and surfaces as an unhandled
    zone error instead of a <code>Left</code>.
  </p>
  <p>
    A source error passes through both operators untouched. Convert
    those with <code>attempt</code> upstream when you want them as
    <code>Left</code>s too.
  </p>

  <h2>Demo 1 · A raise becomes Left, a return becomes Right</h2>
  {{playground:0}}

  <h2>Demo 2 · mapEitherAsync, one event at a time</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: a thrown exception stays on the error channel, and the
    chain continues past it.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="attempt.html"><code>attempt</code></a> — the boundary that turns a throw into a <code>Left</code> ·
    <a href="raise.html"><code>either</code> builder</a> — the same raise scope, on a single value ·
    <a href="separated.html"><code>rights</code> / <code>separated</code></a> — split the resulting <code>Either</code>s
  </div>
