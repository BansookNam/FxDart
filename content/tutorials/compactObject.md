---
slug: compactObject
title: compactObject — FxDart 101
description: FxDart compactObject tutorial: shallowly drop null-valued keys from a Map.
heading: <code>compactObject</code>
section: 9
crumb: compactObject
prev: evolve.html
prevLabel: evolve
next: resolveProps.html
nextLabel: resolveProps
---
  <p class="hero-sub">Returns a copy of a <code>Map</code> with every <code>null</code>-valued key removed — one level deep.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>compactObject</code> is the <code>Map</code> counterpart of
    <a href="compact.html"><code>compact</code></a> (which strips
    <code>null</code>s out of an <code>Iterable</code>). It's handy for
    cleaning up a form or a partially-filled record before serializing it —
    drop the fields nobody filled in, keep everything else.
  </p>
  <p>
    The cleanup is <strong>shallow</strong>: it only inspects the top-level
    values. A <code>null</code> nested two levels down, inside a value
    that's itself a <code>Map</code>, is left completely alone. If you need
    a recursive clean, you'd write that pass yourself (or call
    <code>compactObject</code> again on the nested map before assembling the
    outer one).
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Proof it's shallow</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>compactObject</code> to drop the null-valued keys in <code>draft</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="compact.html"><code>compact</code></a> — the <code>Iterable</code> version ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — a related value-based check ·
    <a href="omitBy.html"><code>omitBy</code></a> — the general predicate version this specializes ·
    <a href="evolve.html"><code>evolve</code></a> — transform values instead of dropping them
  </div>
