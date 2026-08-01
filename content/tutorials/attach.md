---
slug: attach
title: attach — FxDart 101
description: FxDart attach tutorial: pair each value with what you derive from it — the input stays beside its result — with a live playground.
heading: <code>attach</code>
section: 3
crumb: attach
prev: pluck.html
prevLabel: pluck
next: filter.html
nextLabel: filter
---
  <p class="hero-sub">Pair each value with what you derive from it — the input stays beside its result.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="map.html">map</a></code> replaces each value with its
    result — and the moment you need the <em>input</em> again downstream
    (to fall back, to label, to log), you find yourself hand-building
    records: <code>.map((x)&nbsp;async&nbsp;=&gt;&nbsp;(x,&nbsp;await&nbsp;f(x)))</code>.
    <code>attach(f)</code> is that idiom as an operator: it yields
    <code>(value, f(value))</code> pairs, lazily.
  </p>
  <p>
    It earns its keep in async chains. Look up a price per item and the
    pair keeps the item next to the (maybe missing) price, so the fallback
    <code>r.$2&nbsp;??&nbsp;r.$1.listPrice</code> and the "which SKU was
    that?" label are both still in reach. The async form is built on
    <code>mapAsync</code>, so it is parallel-safe — put
    <code><a href="concurrent.html">concurrent(n)</a></code> after it and
    <em>n</em> lookups run at once.
  </p>
  <p>
    Dart-native addition (no FxTS counterpart). When you only need the
    derived value, keep using <code>map</code>; when you need it keyed by
    the input as a lookup table, that is
    <code><a href="indexBy.html">indexBy</a></code>.
  </p>

  <h2>Demo 1 · The input survives the map</h2>
  {{playground:0}}

  <h2>Demo 2 · Async lookups with fallback</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: keep each query beside its search results.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="map.html"><code>map</code></a> — when the input can go ·
    <a href="zip.html"><code>zip</code></a> — pairing two <em>separate</em> sequences ·
    <a href="concurrent.html"><code>concurrent</code></a> — bound the async fan-out after attaching
  </div>
