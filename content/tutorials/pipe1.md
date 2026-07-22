---
slug: pipe1
title: pipe1 — FxDart 101
description: FxDart pipe1 tutorial: apply one function to a value, awaiting it first if it's a Future.
heading: <code>pipe1</code>
section: 1
crumb: pipe1
prev: pipe.html
prevLabel: pipe
next: toList.html
nextLabel: toList
---
  <p class="hero-sub">Applies one function to a value, awaiting it first if the value is a Future.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>pipe1</code> is the single-step building block that <code>pipe</code>
    uses internally: apply <code>f</code> to <code>a</code>, but if
    <code>a</code> is a <code>Future</code>, await it first. If <code>a</code>
    is a plain value, <code>f</code> runs immediately and <code>pipe1</code>
    returns whatever <code>f</code> returns — synchronously, with no
    <code>Future</code> wrapper at all.
  </p>
  <p>
    The point is that <code>f</code> itself never has to know or care
    whether the value it receives came from sync or async work upstream —
    <code>pipe1</code> normalizes that for you. This is handy when you're
    composing a value that's <em>sometimes</em> a <code>Future</code>
    (say, the result of an earlier async step) and you want the next step
    to look identical either way.
  </p>
  <p>
    Because it only handles one step, you can nest <code>pipe1</code> calls
    to compose a short chain, or reach for the full <code>pipe</code> (a
    <code>List&lt;Function&gt;</code>) when there are more than one or two
    steps.
  </p>

  <h2>Demo 1 · A plain (non-Future) value</h2>
  <p>With no <code>Future</code> involved, <code>pipe1</code> just calls
    <code>f(a)</code> directly and returns a plain value:</p>
  {{playground:0}}

  <h2>Demo 2 · Awaiting a Future first</h2>
  <p>
    When <code>a</code> is a <code>Future</code>, <code>pipe1</code> awaits
    it before calling <code>f</code> — chain a few of these together to
    compose async steps one at a time:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>pipe1</code> to turn a delayed name into a greeting.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pipe.html"><code>pipe</code></a> — multi-step pipeline built from pipe1 ·
    <a href="fx.html"><code>fx</code></a> — the typed chain alternative ·
    <a href="delay.html"><code>delay &amp; sleep</code></a> — the async helpers used above
  </div>
