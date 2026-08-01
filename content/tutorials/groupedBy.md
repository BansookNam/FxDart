---
slug: groupedBy
title: groupedBy — FxDart 101
description: FxDart groupedBy tutorial: groups as chainable (key, items) records — aggregate per group without re-entering through Map.entries — with a live playground.
heading: <code>groupedBy</code>
section: 7
crumb: groupedBy
prev: groupBy.html
prevLabel: groupBy
next: indexBy.html
nextLabel: indexBy
---
  <p class="hero-sub">Groups as chainable <code>(key, items)</code> records — aggregate per group without leaving the pipeline.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="groupBy.html">groupBy</a></code> is a terminal: it hands
    you a <code>Map</code>, and the moment you want "total per group,
    sorted, top 3" you are re-entering the pipeline through
    <code>fx(map.entries)</code> with <code>kv.key</code> /
    <code>kv.value</code> ceremony. <code>groupedBy</code> is the same
    grouping as a <strong>chainable view</strong>: each group is a named
    record <code>(key:&nbsp;…, items:&nbsp;…)</code>, so per-group
    aggregation, sorting, and taking continue in the very same chain —
    and downstream code reads <code>g.key</code> / <code>g.items</code>
    instead of positional <code>$1</code> / <code>$2</code>.
  </p>
  <p>
    Groups appear in <strong>first-seen key order</strong>, exactly like
    <code>groupBy</code>'s map iterates. Like
    <code><a href="sortBy.html">sortBy</a></code>, it must see every value
    before it can yield the first group, so the grouping itself is eager
    while the chain around it stays composable.
  </p>
  <p>
    This is a Dart-native addition (no FxTS counterpart) — reach for
    <code>groupBy</code> when you want keyed lookups, and
    <code>groupedBy</code> when the groups are just an intermediate step
    of a longer pipeline.
  </p>

  <h2>Demo 1 · Group → aggregate → rank, one chain</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: top spending category without touching <code>Map.entries</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — the same grouping as a keyed <code>Map</code> ·
    <a href="countBy.html"><code>countBy</code></a> — when the only aggregate is a count ·
    <a href="sortByDesc.html"><code>sortByDesc</code></a> — the natural next step for rankings
  </div>
