---
slug: resolveProps
title: resolveProps — FxDart 101
description: FxDart resolveProps tutorial: await every value in a Map at once, the map-shaped analogue of Future.wait.
heading: <code>resolveProps</code>
section: 9
crumb: resolveProps
prev: compactObject.html
prevLabel: compactObject
next: isMatch.html
nextLabel: isMatch
---
  <p class="hero-sub">Awaits every value of a <code>Map</code> and returns the resolved <code>Map</code> — the map-shaped analogue of <code>Future.wait</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>resolveProps</code> solves a specific, common shape of problem:
    you have a <code>Map</code> whose values are a mix of plain values and
    <code>Future</code>s — say, several independent API calls keyed by
    field name — and you want one <code>Future</code> back for the whole,
    fully-resolved map.
  </p>
  <p>
    Internally it loops over the entries and <code>await</code>s each value
    in turn, which reads like it should be <em>sequential</em>. In
    practice, it usually isn't slower than doing them all "at once": a Dart
    <code>Future</code> starts running the moment it's <em>created</em>, not
    when it's awaited. So if you build the map with
    <code>delay(...)</code> or already-in-flight requests as its values —
    the normal way to call this function — every one of them is already
    racing by the time <code>resolveProps</code> gets the map; its
    sequential <code>await</code> loop is just reading off results that are
    largely ready already, not gating when the work starts. The demo below
    proves this with a stopwatch.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · The futures already overlap</h2>
  <p>Three 100ms delays, but the whole thing finishes well under 300ms — because they all started together:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>resolveProps</code> to await every value in <code>requests</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="evolve.html"><code>evolve</code></a> — the sync cousin, transforming instead of awaiting ·
    <a href="concurrent.html"><code>concurrent</code></a> — the iterable-shaped version of "run things together" ·
    <a href="delay.html"><code>delay &amp; sleep</code></a> — used to build the demo futures ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — build a Map from scratch
  </div>
