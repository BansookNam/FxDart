---
slug: fxPipe
title: fxPipe — FxDart 101
description: FxDart fxPipe tutorial: typed left-to-right function composition — fxPipe3 or fxPipe(parse).then(normalise).then(score), with a live playground.
heading: <code>fxPipe</code>
section: 10
crumb: fxPipe
prev: juxt.html
prevLabel: juxt
next: memoize.html
nextLabel: memoize
---
  <p class="hero-sub">Typed left-to-right composition. The last <code>.then</code> <em>is</em> the function — no <code>.build()</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>pipe</code> threads a value through a list of functions, but the
    list is <code>dynamic</code>. <code>fxPipe</code> is the typed form that
    returns a function:
  </p>
  <pre><code>final f = fxPipe3(parse, normalise, score);
f(line);
fx(lines).map(f);</code></pre>
  <p>
    Each <code>.then</code> returns the chain so far, so there is nothing
    to "finish." Call it, or pass it to <code>map</code> /
    <code><a href="parallel.html">parallel</a></code>.
    <code>fxPipe(parse)</code> is just <code>parse</code> — the name marks
    the start. <code>parse.then(normalise)</code> works too.
  </p>
  <p>
    Two <code>.parallel</code> calls copy every result back to this isolate
    and out again. One composed worker pays the hop once:
  </p>
  <pre><code>await fx(lines)
    .parallel(4, fxPipe3(parse, normalise, score), chunked: true)
    .toList();</code></pre>
  <p>
    Stages must be sendable when the result is a
    <code>parallel</code> worker. <code>juxt</code> is the other
    direction: several functions, one input, a list of results.
  </p>
  <p>
    <code>fxPipe2</code>..<code>fxPipe5</code> fuse the same stages into
    one closure, so a hot <code>map</code> or
    <code>parallel</code> worker does not pay a nested call per
    <code>.then</code>. Arity stops at 5, like
    <code>zipOrAccumulate2..5</code>. Longer than that, keep chaining
    <code>.then</code> or write the fused function yourself.
  </p>
  <p>
    <code>parallel</code> is VM-only, so the playgrounds below run the
    same composed function through <code>map</code>.
  </p>

  <h2>Demo 1 · parse, normalise, score</h2>
  <p>
    Three stages, one function. On the VM you would pass this to
    <code>parallel</code>; here it runs in the playground.
  </p>
  {{playground:0}}

  <h2>Demo 2 · Same numbers as three maps</h2>
  <p>
    <code>fxPipe</code> is composition, not a new operator. Three
    <code>map</code>s and one composed function print the same list.
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: compose <code>parse</code> → <code>normalise</code> →
    <code>score</code> and keep only rows that score at least 4.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pipe.html"><code>pipe</code></a> — the same idea, untyped, over a value ·
    <a href="juxt.html"><code>juxt</code></a> — several functions, one input, a list of results ·
    <a href="map.html"><code>map</code></a> — the same composition on this isolate ·
    <a href="parallel.html"><code>parallel</code></a> — where composing workers saves a hop
  </div>
