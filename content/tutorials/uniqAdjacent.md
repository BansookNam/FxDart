---
slug: uniqAdjacent
title: uniqAdjacent — FxDart 101
description: FxDart uniqAdjacent tutorial: drop only adjacent duplicates — state-change detection without a growing seen-set — with a live playground.
heading: <code>uniqAdjacent</code>
section: 4
crumb: uniqAdjacent
prev: uniqStrict.html
prevLabel: uniqStrict
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">Drops elements equal to their predecessor — only <em>adjacent</em> duplicates go, and no seen-set builds up.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="uniq.html">uniq</a></code> answers "have I <em>ever</em>
    seen this value?" — it keeps a set of everything seen so far.
    <code>uniqAdjacent()</code> answers a different question:
    "did the value <em>change</em>?" It compares each element only with
    its immediate predecessor, so <code>[1, 1, 2, 2, 1]</code> becomes
    <code>(1, 2, 1)</code> — the trailing <code>1</code> survives, because
    it is a <em>new run</em>, not a repeat of the current one.
  </p>
  <p>
    That makes it the operator for collapsing runs: status feeds that
    re-report the same state every tick, sensor values that plateau, log
    streams that repeat a level. And because there is no seen-set, memory
    stays constant no matter how long the sequence — safe on endless
    sources where <code>uniq</code> would grow forever.
    <code>uniqAdjacentBy(key)</code> compares by a derived key, mirroring
    <code><a href="uniqBy.html">uniqBy</a></code>.
  </p>
  <p>
    fxdart extension (no FxTS counterpart) — Rx calls it
    <code>distinctUntilChanged</code>, Dart streams call it
    <code>Stream.distinct</code>. The async key callback runs one element
    at a time (the comparison is inherently ordered), but the upstream
    still evaluates in parallel under
    <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · Collapse runs, keep returns</h2>
  {{playground:0}}

  <h2>Demo 2 · State changes by key</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: report only the moments a sensor's zone changes.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="uniq.html"><code>uniq</code></a> — global dedup with a seen-set ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — global dedup by key ·
    <a href="pairwise.html"><code>pairwise</code></a> — when you need both sides of the change
  </div>
