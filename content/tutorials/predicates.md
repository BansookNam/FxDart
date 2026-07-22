---
slug: predicates
title: predicates — FxDart 101
description: FxDart type predicates: isNull, isBool, isNum, isString, isDateTime, isList, isMap, and friends, as filter-friendly tear-offs.
heading: <code>predicates</code>
section: 8
crumb: predicates
prev: some.html
prevLabel: some
next: fromEntries.html
nextLabel: fromEntries
---
  <p class="hero-sub">A small family of type/value checks, kept around as tear-off-friendly functions for <code>filter</code>, <code>takeWhile</code>, and friends.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    In everyday Dart you'd just write <code>a is String</code> — that's
    idiomatic, and nothing here replaces it. These functions exist for one
    specific reason: Dart's <code>is</code> operator can't be torn off as a
    first-class function value, but <code>filter</code>, <code>takeWhile</code>,
    <code>find</code>, and friends all want a <code>bool Function(A)</code>.
    <code>filter(isString, mixedList)</code> reads better than
    <code>filter((a) => a is String, mixedList)</code>, and that's the whole
    point of this page.
  </p>
  <p>
    <code>isNil</code> is a straight port of FxTS's "is <code>null</code> or
    <code>undefined</code>" check — since Dart collapses both into
    <code>null</code>, it's byte-for-byte identical to <code>isNull</code>.
    Three more names exist purely for FxTS parity and are marked
    <code>@Deprecated</code>: <code>isUndefined</code> (there's no
    <code>undefined</code> in Dart, so it's just <code>isNull</code>),
    <code>isArray</code> (JS <code>Array</code> → Dart <code>List</code>, so
    it's <code>isList</code>), and <code>isObject</code> (JS plain object →
    Dart <code>Map</code>, so it's <code>isMap</code>). Reach for the
    non-deprecated name in new code; the aliases are there so ported call
    sites still compile.
  </p>

  <h2>Demo 1 · Filter-friendly tear-offs</h2>
  {{playground:0}}

  <h2>Demo 2 · <code>isNil</code> and the deprecated aliases</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>isNotNull</code> to filter the <code>null</code> out of <code>row</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="filter.html"><code>filter</code></a> — the usual place these get plugged in ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — a value-based check, not a type check ·
    <a href="compact.html"><code>compact</code></a> — drop nulls from an iterable ·
    <a href="matches.html"><code>matches</code></a> — a predicate for shape, not type
  </div>
