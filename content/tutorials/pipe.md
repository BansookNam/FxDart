---
slug: pipe
title: pipe — FxDart 101
description: FxDart pipe tutorial: left-to-right function composition over a value, dynamically typed — and why fx() chains are the typed alternative.
heading: <code>pipe</code>
section: 1
crumb: pipe
prev: fx.html
prevLabel: fx
next: pipe1.html
nextLabel: pipe1
---
  <p class="hero-sub">Runs a value through a list of functions, left to right — dynamically typed.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    In FxTS, <code>pipe(x, f, g, h)</code> is a curried, fully-typed
    pipeline: TypeScript has enough overloads and generics tricks to infer
    the type flowing out of each step. <strong>Dart cannot do this.</strong>
    There is no variadic-generic overload trick available, so FxDart's
    <code>pipe</code> is honest about the trade-off: it takes a plain
    <code>List&lt;Function&gt;</code> and threads a <code>dynamic</code>
    value through each one in order. Each function receives whatever the
    previous one returned, with no static type checking in between.
  </p>
  <p>
    That means <code>pipe</code> still works, and still reads nicely for a
    short, throwaway transformation — but a step that expects the wrong
    type will only fail at <em>run time</em>, and the whole pipeline's
    result type is just <code>dynamic</code>. If a step in the list
    returns a <code>Future</code>, <code>pipe</code> automatically awaits
    it before feeding the value to the next step, so sync and async
    functions can sit in the same list.
  </p>
  <p>
    For anything you'll keep and maintain, prefer the <code>fx()</code>
    chain instead: <code>fx(x).map(f).filter(g)</code> is fully typed, gets
    autocomplete, and catches mismatched types at compile time — it's the
    typed alternative to exactly this kind of pipeline. Reach for
    <code>pipe</code> when the steps are dynamic by nature (e.g. built from
    a runtime list of functions) or when you're prototyping quickly.
    <code>pipeLazy</code> is the same idea, deferred: it returns a function
    you can call later instead of running immediately.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>A short pipeline built from FxDart's data-first functions:</p>
  {{playground:0}}

  <h2>Demo 2 · The honest downside</h2>
  <p>
    A step that expects the wrong type compiles fine and only blows up when
    it actually runs — this is exactly what <code>fx()</code> chains are
    designed to prevent:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: pipe a list of numbers through a filter step and a sum step.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fx.html"><code>fx</code></a> — the typed chain alternative ·
    <a href="pipe1.html"><code>pipe1</code></a> — a single pipe step, sync/async aware ·
    <a href="toArray.html"><code>toArray</code></a> — common final step in a pipe
  </div>
