---
slug: dropRight
title: dropRight — FxDart 101
description: FxDart dropRight tutorial: omit the last n values of a finite iterable, with a live playground.
heading: <code>dropRight</code>
section: 5
crumb: dropRight
prev: drop.html
prevLabel: drop
next: dropWhile.html
nextLabel: dropWhile
---
  <p class="hero-sub">Returns a lazy iterable that omits the last <code>length</code> values.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>dropRight</code> omits the last <code>length</code> values instead
    of the first. As with <code>takeRight</code>, there's no way to know
    which elements are "last" without seeing the whole source, so
    <code>dropRight</code> <strong>materializes</strong> it into a list
    before yielding anything. It's the right tool when you have, say, a
    known-size batch and want everything except a trailing footer or
    sentinel — but it needs a finite source.
  </p>
  <p>
    <code>dropRightAsync</code> carries the same constraint: it awaits the
    entire upstream before it can start producing values.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async (must buffer the whole source first)</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop the last 2 footer lines.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="drop.html"><code>drop</code></a> — drop from the front instead ·
    <a href="takeRight.html"><code>takeRight</code></a> — keep the last n instead of dropping them ·
    <a href="reverse.html"><code>reverse</code></a> — also materializes the source
  </div>
