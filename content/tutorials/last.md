---
slug: last
title: lastOrNull — FxDart 101
description: FxDart lastOrNull: get the final element of an iterable, null-safe on empty input, plus a chain-getter gotcha to watch for.
heading: <code>lastOrNull</code>
section: 8
crumb: lastOrNull
prev: head.html
prevLabel: head
next: nth.html
nextLabel: nth
---
  <p class="hero-sub">Returns the final element of an iterable, or <code>null</code> when it's empty.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>lastOrNull</code> walks the whole iterable and hands back whatever
    it saw most recently — <code>null</code> if it never saw anything.
    <code>lastOrNull</code> is the Dart-idiomatic name (it mirrors
    <code>Iterable.lastOrNull</code>); fxdart also accepts the FxTS spelling
    <code>last</code> — they're the same operator. Unlike
    <code>head</code>, there's no shortcut: since a lazy iterable doesn't
    know where it ends without being asked, <code>lastOrNull</code> has to
    consume every element, so it's <code>O(n)</code> even though the pipeline
    upstream may be lazily built.
  </p>
  <p>
    <strong>Watch out on the sync chain:</strong> <code>Fx</code> extends
    <code>Iterable</code>, so <code>fx(iterable).lastOrNull</code> resolves to
    Dart's own inherited <code>Iterable.lastOrNull</code> <em>getter</em>
    (no parens) — which <em>is</em> null-safe and returns <code>null</code> on
    an empty iterable. The trap is the neighboring <code>.last</code> getter
    (no "OrNull"): <code>fx(&lt;int&gt;[]).last</code> throws
    <code>StateError</code> instead of returning <code>null</code>. Reach for
    <code>.lastOrNull</code>, or the top-level <code>lastOrNull(iterable)</code>
    function. On the <em>async</em> chain, <code>.lastOrNull()</code> is a
    method — with parens.
  </p>

  <h2>Demo 1 · Basics, and the chain getter trap</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, where the chain form IS null-safe</h2>
  <p><code>FxAsync</code> defines its own <code>.lastOrNull()</code> method, so on the async chain the getter trap above doesn't apply:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>lastOrNull</code> so this prints the final log line, or <code>'no logs yet'</code> when there are none.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="head.html"><code>head</code></a> — the O(1) opposite end ·
    <a href="nth.html"><code>nth</code></a> — pull any index ·
    <a href="find.html"><code>find</code></a> — first match to a predicate ·
    <a href="reverse.html"><code>reverse</code></a> — flip the whole sequence
  </div>
