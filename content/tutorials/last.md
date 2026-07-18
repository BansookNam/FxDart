---
slug: last
title: last — FxDart 101
description: FxDart last tutorial: get the final element of an iterable, null-safe on empty input, plus a chain-getter gotcha to watch for.
heading: <code>last</code>
section: 8
crumb: last
prev: head.html
prevLabel: head
next: nth.html
nextLabel: nth
---
  <p class="hero-sub">Returns the final element of an iterable, or <code>null</code> when it's empty.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>last</code> walks the whole iterable and hands back whatever it
    saw most recently — <code>null</code> if it never saw anything. Unlike
    <code>head</code>, there's no shortcut: since a lazy iterable doesn't
    know where it ends without being asked, <code>last</code> has to consume
    every element, so it's <code>O(n)</code> even though the pipeline
    upstream may be lazily built.
  </p>
  <p>
    <strong>Watch out on the sync chain:</strong> <code>Fx</code> extends
    <code>Iterable</code>, and there is no <code>Fx.last()</code> override —
    so <code>fx(iterable).last</code> resolves to Dart's own
    <code>Iterable.last</code> <em>getter</em>, which throws
    <code>StateError</code> on an empty iterable instead of returning
    <code>null</code>. The null-safe behavior only exists as the top-level
    <code>last(iterable)</code> function (or <code>.last()</code> on the
    <em>async</em> chain, which does have its own override). When in doubt,
    prefer the top-level function.
  </p>

  <h2>Demo 1 · Basics, and the chain getter trap</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, where the chain form IS null-safe</h2>
  <p><code>FxAsync</code> defines its own <code>.last()</code>, so on the async chain the getter trap above doesn't apply:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>last</code> so this prints the final log line, or <code>'no logs yet'</code> when there are none.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="head.html"><code>head</code></a> — the O(1) opposite end ·
    <a href="nth.html"><code>nth</code></a> — pull any index ·
    <a href="find.html"><code>find</code></a> — first match to a predicate ·
    <a href="reverse.html"><code>reverse</code></a> — flip the whole sequence
  </div>
