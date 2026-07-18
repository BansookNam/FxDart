---
slug: identity
title: identity — FxDart 101
description: FxDart identity tutorial: the function that returns its argument unchanged, and why that's useful as a default callback.
heading: <code>identity</code>
section: 10
crumb: identity
prev: matches.html
prevLabel: matches
next: always.html
nextLabel: always
---
  <p class="hero-sub">Returns its argument unchanged.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>identity</code> is the simplest function in the library, and one of
    the most useful: it takes a value and hands it straight back. On its own
    that looks pointless. Its value shows up whenever an API <em>expects a
    function</em> but you don't actually want to transform anything — a
    default key function for <code>groupBy</code>/<code>sortBy</code>, a
    placeholder branch in a dispatch table, or the "no-op" arm of a
    conditional pipeline.
  </p>
  <p>
    Because <code>identity</code> is generic (<code>T identity&lt;T&gt;(T a)</code>),
    it slots into any unary-function position without you writing
    <code>(x) => x</code> yourself. It has no async variant and no chain
    form — it's a plain value-in, value-out function you pass around.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>Used directly, and as the key function for a grouping operation where
    "group by the value itself" is exactly what you want:</p>
  {{playground:0}}

  <h2>Demo 2 · As the "do nothing" branch</h2>
  <p>
    A dispatch table of string transforms, where one entry deliberately does
    nothing — <code>identity</code> fills that slot cleanly instead of a
    hand-written no-op lambda:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>sortBy</code> takes a key function. Use <code>identity</code>
    as that key to sort this list of words by their natural (string) order.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="always.html"><code>always</code></a> — a constant instead of a pass-through ·
    <a href="tap.html"><code>tap</code></a> — pass through, but run a side effect first ·
    <a href="cases.html"><code>cases</code></a> — dispatch table with predicates ·
    <a href="sortBy.html"><code>sortBy</code></a> — a common home for a key function
  </div>
