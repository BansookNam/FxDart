---
slug: apply
title: apply — FxDart 101
description: FxDart apply tutorial: invoke a function with arguments collected in a List, with a live playground.
heading: <code>apply</code>
section: 10
crumb: apply
prev: tap.html
prevLabel: tap
next: juxt.html
nextLabel: juxt
---
  <p class="hero-sub">Calls a function with a List of arguments as its positional parameters.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>apply</code> exists for the moments when the arguments to a call
    aren't sitting in separate variables — they're already collected in a
    <code>List</code> (parsed from input, gathered from a config, produced by
    <a href="juxt.html"><code>juxt</code></a>) and you need to invoke an
    arbitrary function with them. Under the hood it's a thin wrapper over
    Dart's own <code>Function.apply</code>, with the result cast to <code>R</code>.
  </p>
  <p>
    Because <code>f</code> is typed as the bare <code>Function</code>,
    <code>apply</code> is inherently dynamic — Dart can't check the argument
    count or types against <code>f</code>'s signature at compile time, only at
    runtime. Reach for it only when you genuinely have a dynamic arg list;
    for anything else, call the function directly.
  </p>
  <p>
    A related but separate concern is <em>currying</em> — pre-filling some
    arguments of a function ahead of time. FxTS has a fully generic
    <code>curry</code>; Dart's type system has no equivalent for arbitrary
    arities, so FxDart ships only a
    <code>@Deprecated</code> two-argument <code>curry</code> stub as a
    migration aid. Prefer writing the closure yourself:
    <code>(b) => f(a, b)</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Dispatching dynamic calls</h2>
  <p>
    A small command dispatcher, where each handler has a different arity and
    the arguments arrive as a runtime <code>List</code>:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: call <code>greet</code> below using <code>apply</code> with the
    argument list <code>['Kim', 'Hello']</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="juxt.html"><code>juxt</code></a> — often the source of a dynamic arg list ·
    <a href="tap.html"><code>tap</code></a> — run a side effect without changing the value ·
    <a href="cases.html"><code>cases</code></a> — dispatch on predicates instead of a name ·
    <a href="pipe.html"><code>pipe</code></a> — dynamic composition, same trade-off as apply
  </div>
