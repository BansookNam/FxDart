---
slug: groupsBy
title: groupsBy — FxDart 101
description: FxDart groupsBy tutorial: live GroupedEvents of key and events as each key opens, with lastFor to close a group — with a live playground.
heading: <code>groupsBy</code>
section: 14
crumb: groupsBy
prev: windowOn.html
prevLabel: windowOn
next: spaceBy.html
nextLabel: spaceBy
---
  <p class="hero-sub">Live groups as they open: a key and an inner stream of every later value that shares it.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The pull layer's <code><a href="groupBy.html">groupBy</a></code> is a
    terminal: it pulls everything and hands you a <code>Map</code>.
    <code>groupsBy</code> is the live version. The first value of each
    key emits a <code>GroupedEvents</code> — a record of that
    <code>key</code> and an inner <code>events</code> stream — and every
    later value with the same key is forwarded to that inner. Groups
    appear in <strong>first-seen key order</strong>, as they open, not
    after the source has closed.
  </p>
  <p>
    That is the same nested-<code>FxEvents</code> idea as
    <code><a href="windowOn.html">window*</a></code>, keyed by value
    instead of by time. A widget can subscribe to one group's inner the
    moment it appears and see later values as they arrive; it does not
    have to wait for a batch.
  </p>
  <p>
    If <code>lastFor</code> is set, the first event (or completion) of
    <code>lastFor(key)</code> <strong>completes that group</strong>. A
    later value with the same key opens a new one — an idle timeout per
    user, a "session ended" signal per room. Without
    <code>lastFor</code>, groups stay open until the source completes
    (or errors, which errors every live group then the outer).
  </p>
  <p>
    Cancelling the outer completes live groups silently, the same RxJS 9
    rule the window family follows. fxdart events layer, after Rx's
    <code>groupBy</code>.
  </p>

  <h2>Demo 1 · Groups as they open</h2>
  {{playground:0}}

  <h2>Demo 2 · lastFor closing a group</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: group SKUs by department prefix.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — the same grouping as a keyed <code>Map</code>, on the pull layer ·
    <a href="groupedBy.html"><code>groupedBy</code></a> — pull-layer groups as chainable <code>(key, items)</code> records ·
    <a href="windowOn.html"><code>window*</code></a> — live inners rotated by count, trigger, or clock
  </div>
