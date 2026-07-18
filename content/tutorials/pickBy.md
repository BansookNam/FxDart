---
slug: pickBy
title: pickBy — FxDart 101
description: FxDart pickBy tutorial: keep only Map entries matching a (key, value) predicate.
heading: <code>pickBy</code>
section: 9
crumb: pickBy
prev: omitBy.html
prevLabel: omitBy
next: prop.html
nextLabel: prop
---
  <p class="hero-sub">Returns a copy of a <code>Map</code> with only the entries matching a predicate.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>pickBy</code> is <code>omitBy</code>'s mirror, and shares its
    calling convention: the predicate receives one <code>(K, V)</code>
    record per entry, so use <code>e.$1</code> for the key and
    <code>e.$2</code> for the value. Only entries where the predicate
    returns <code>true</code> survive into the result.
  </p>
  <p>
    A common use: filtering a map of config values or feature flags down to
    "the ones that matter right now" — active flags, keys with a given
    prefix, values above a threshold — without hand-writing an
    entry-by-entry loop.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Filtering by key</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>pickBy</code> to keep only entries whose value is <code>true</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="omitBy.html"><code>omitBy</code></a> — the inverse: drop by predicate ·
    <a href="pick.html"><code>pick</code></a> — keep by a fixed key list ·
    <a href="matches.html"><code>matches</code></a> — a ready-made predicate for shape matching ·
    <a href="compactObject.html"><code>compactObject</code></a> — a specialized "drop nulls" pickBy
  </div>
