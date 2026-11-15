---
slug: none
title: none — FxDart 101
description: FxDart none tutorial: true when no element matches — the third quantifier beside every and some, short-circuiting on the first match, sync and async.
heading: <code>fxNone</code>
section: 8
crumb: none
prev: atLeast.html
prevLabel: atLeast
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">"Does nothing match?" — said as a universal, and answered at the first counter-example.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>fxNone(f, xs)</code> is <code>true</code> when <code>f</code>
    holds for no element. You could always write it as
    <code>!fxSome(f, xs)</code>, and the answer is the same — but that
    reads as a negated existential ("it is not the case that some…"), and
    negation is where quantifier bugs live: the <code>!</code> drifts to
    the wrong side of a <code>&amp;&amp;</code>, or gets dropped in a
    refactor. <code>none</code> says the rule the way you would state it.
  </p>
  <p>
    It is the third quantifier beside
    <code><a href="every.html">every</a></code> and
    <code><a href="some.html">any</a></code>, and the three are tied
    together: <code>none(f)</code> is <code>!any(f)</code>, it is
    <code>every((x)&nbsp;=&gt;&nbsp;!f(x))</code>, and it is
    <code><a href="atLeast.html">atMost</a>(0, f)</code>. Like
    <code>any</code> it <strong>short-circuits</strong>: the first match
    decides the answer (<code>false</code>) and the rest is never tested.
    An empty input has no counter-example, so it is <code>true</code>.
  </p>
  <p>
    On the chain it is <code>fx(xs).none(f)</code>;
    <code>fxNoneAsync</code> and <code>fxAsync(…).none(f)</code> accept a
    predicate that awaits and cancel upstream at the deciding match.
    Dart-native addition — FxTS has only <code>every</code>/<code>some</code>;
    Kotlin spells it <code>none</code>. It is unrelated to
    <code>SingletonRaise.none()</code> in the
    <a href="nullable.html">nullable</a> builder, which short-circuits a raise
    scope; that one is a member, so neither name shadows the other.
  </p>

  <h2>Demo 1 · No match, empty input, early stop</h2>
  {{playground:0}}

  <h2>Demo 2 · Three spellings, and async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop the <code>!</code> and say the rule directly.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="some.html"><code>any</code></a> — <code>none</code> is its negation ·
    <a href="every.html"><code>every</code></a> — the universal quantifier ·
    <a href="atLeast.html"><code>atMost</code></a> — <code>atMost(0, f)</code> is <code>none</code>
  </div>
