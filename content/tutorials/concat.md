---
slug: concat
title: concat — FxDart 101
description: FxDart concat tutorial: chain two lazy iterables end to end, with a live playground.
heading: <code>concat</code>
section: 6
crumb: concat
prev: prepend.html
prevLabel: prepend
next: zip.html
nextLabel: zip
---
  <p class="hero-sub">Lazily yields all of the first iterable, then all of the second.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>concat</code> chains two iterables end to end without copying
    either one into a new list. It's fully lazy on both sides: the second
    iterable is never touched at all unless the pipeline actually pulls past
    the end of the first — so concatenating an expensive or infinite first
    source with a second one is safe as long as you don't demand more than
    the first source has.
  </p>
  <p>
    <code>concatAsync</code> is a pass-through, like <code>take</code> and
    <code>concat</code>'s async cousins: it doesn't serialize either side
    internally, so a <code>concurrent(n)</code> further downstream still
    gets to overlap pulls against whichever side is currently active.
  </p>

  <h2>Demo 1 · Basics &amp; laziness</h2>
  <p>The second iterable is a generator with a side effect — watch it never
    run because <code>take(2)</code> is satisfied by the first list alone:</p>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: concatenate <code>morning</code> and <code>evening</code>
    into one schedule.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="append.html"><code>append</code></a> — add just one trailing value ·
    <a href="prepend.html"><code>prepend</code></a> — add just one leading value ·
    <a href="zip.html"><code>zip</code></a> — pair up elements instead of chaining them
  </div>
