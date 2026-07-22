---
slug: split
title: split — FxDart 101
description: FxDart split tutorial: split a character iterable on a separator, with a live playground.
heading: <code>split</code>
section: 5
crumb: split
prev: chunk.html
prevLabel: chunk
next: append.html
nextLabel: append
---
  <p class="hero-sub">Splits an iterable of single-character strings on a separator character.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>split</code> is a direct port of FxTS's character-wise
    <code>split</code>, and that shows in its signature: it doesn't take a
    <code>String</code> at all — it takes an <code>Iterable&lt;String&gt;</code>
    of single characters, and walks it one character at a time, accumulating
    a piece until it sees one equal to <code>sep</code>. In Dart, the
    idiomatic way to get that character iterable is
    <code>myString.split('')</code> (Dart's own <code>String.split</code>
    with an empty pattern breaks a string into its individual characters).
  </p>
  <p>
    A trailing separator produces a trailing empty string in the output,
    matching FxTS's behavior — <code>'a,b,'</code> splits into
    <code>('a', 'b', '')</code>, not just <code>('a', 'b')</code>. There's no
    <code>Fx</code> chain form for <code>split</code>; call the top-level
    function (or <code>splitAsync</code>) directly.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>split</code> to break <code>csv</code> into color
    names on <code>'|'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="chunk.html"><code>chunk</code></a> — group by fixed size instead of separator ·
    <a href="unicodeToList.html"><code>unicodeToList</code></a> — get a proper character array (grapheme-aware) ·
    <a href="join.html"><code>join</code></a> — the inverse operation
  </div>
