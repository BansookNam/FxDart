---
slug: unicodeToList
title: unicodeToList — FxDart 101
description: FxDart unicodeToList tutorial: split a string into user-perceived characters, correctly handling surrogate pairs like emoji.
heading: <code>unicodeToList</code>
section: 10
crumb: unicodeToList
prev: delay.html
prevLabel: delay &amp; sleep
next: curried.html
nextLabel: curried &amp; uncurried
---
  <p class="hero-sub">Splits a string into user-perceived characters, correctly handling surrogate pairs.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Dart <code>String</code>s are sequences of UTF-16 <em>code units</em>, not
    characters. Calling <code>s.split('')</code> splits by code unit — fine
    for plain ASCII/Latin text, but wrong for anything outside the Basic
    Multilingual Plane, like most emoji: those are represented as a
    <strong>surrogate pair</strong> (two code units), so a naive split tears
    a single emoji into two broken halves.
  </p>
  <p>
    <code>unicodeToList</code> fixes that by iterating the string's
    <code>.runes</code> — Unicode code points — and turning each one back
    into its own single-character <code>String</code>. The result is the list
    of characters a person actually sees when reading the string, matching
    FxTS's <code>unicodeToList</code>, which splits by code point rather than
    UTF-16 unit.
  </p>

  <h2>Demo 1 · Naive split vs. unicodeToList</h2>
  {{playground:0}}

  <h2>Demo 2 · Reversing and counting correctly</h2>
  <p>
    Building on <code>unicodeToList</code>, a naive-split reverse would
    mangle the emoji; this one doesn't:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: count how many user-perceived characters are in this string
    (it contains an emoji).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="split.html"><code>split</code></a> — split on a plain char iterable ·
    <a href="reverse.html"><code>reverse</code></a> — reverse an Iterable, same surrogate-pair care applies to strings ·
    <a href="countBy.html"><code>countBy</code></a> — used above to tally characters ·
    <a href="identity.html"><code>identity</code></a> — used above as the counting key
  </div>
