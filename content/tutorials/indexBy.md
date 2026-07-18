---
slug: indexBy
title: indexBy — FxDart 101
description: FxDart indexBy tutorial: index every element by a computed key into a Map, last one wins, with a live playground.
heading: <code>indexBy</code>
section: 7
crumb: indexBy
prev: groupBy.html
prevLabel: groupBy
next: countBy.html
nextLabel: countBy
---
  <p class="hero-sub">Indexes every element by a computed key into a <code>Map&lt;K, A&gt;</code> — last duplicate wins.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>indexBy</code> is <code><a href="groupBy.html">groupBy</a></code>'s
    sibling: same idea — pull the whole pipeline, compute a key for each
    element — but instead of collecting a <em>list</em> per key, it keeps
    exactly <strong>one</strong> value per key: <code>Map&lt;K, A&gt;</code>
    rather than <code>Map&lt;K, List&lt;A&gt;&gt;</code>.
  </p>
  <p>
    That means duplicates don't accumulate — they overwrite. If two elements
    produce the same key, whichever one is processed <strong>last</strong>
    (i.e. appears later in the iterable) is the one left in the map. This is
    the natural behavior of repeatedly doing <code>result[key(a)] = a</code>
    while walking forward, and it matches FxTS. Reach for
    <code>indexBy</code> specifically when you know keys should be unique
    (like a database ID) and you want direct <code>O(1)</code> lookup instead
    of a list you'd have to search.
  </p>
  <p>
    If you actually expect duplicate keys and want to keep every value, use
    <code>groupBy</code> instead — it never discards anything.
  </p>

  <h2>Demo 1 · Basics &amp; last-wins</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: index the users <strong>by their id</strong>, so you can look one up directly.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — keeps every duplicate instead of overwriting ·
    <a href="countBy.html"><code>countBy</code></a> — tally instead of keeping the value ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — build a Map from key/value pairs directly
  </div>
