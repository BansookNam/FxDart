---
slug: isMatch
title: isMatch — FxDart 101
description: FxDart isMatch tutorial: deep partial matching against a Map or list pattern.
heading: <code>isMatch</code>
section: 9
crumb: isMatch
prev: resolveProps.html
prevLabel: resolveProps
next: matches.html
nextLabel: matches
---
  <p class="hero-sub">Deep partial match: does <code>target</code> contain everything described by <code>pattern</code>?</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>isMatch</code> recurses through <code>pattern</code> and checks
    that <code>target</code> "contains" it, with different rules per shape:
  </p>
  <p>
    <strong>Maps</strong> match partially — every key in <code>pattern</code>
    must exist in <code>target</code> with a recursively-matching value, but
    <code>target</code> is free to have <em>extra</em> keys the pattern
    doesn't mention. <strong>Lists/iterables</strong> match pairwise from
    the front, and here's the twist worth remembering: the pattern only has
    to be a <strong>prefix</strong> of the target. <code>[1, 2, 3]</code>
    matches the pattern <code>[1, 2]</code>, but <em>not</em> the pattern
    <code>[1, 2, 3, 4]</code> — the pattern can't be longer than the target.
    Anything else (numbers, strings, booleans, …) is compared with plain
    <code>==</code>.
  </p>
  <p>
    Because the rules nest, you get deep matching almost for free: a
    pattern like <code>{'address': {'city': 'seoul'}}</code> matches a user
    map with a much larger, deeply nested <code>address</code> value, as
    long as <code>city</code> is <code>'seoul'</code> somewhere inside it.
  </p>

  <h2>Demo 1 · Map matching</h2>
  {{playground:0}}

  <h2>Demo 2 · List prefix matching, and filtering with it</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>isMatch</code> to check whether <code>order</code> matches <code>{'status': 'shipped'}</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="matches.html"><code>matches</code></a> — the curried, filter-ready version of this ·
    <a href="pickBy.html"><code>pickBy</code></a> — often paired for shape-based filtering ·
    <a href="find.html"><code>find</code></a> — locate the first matching element ·
    <a href="omitBy.html"><code>omitBy</code></a> — drop entries by predicate
  </div>
