---
slug: foldRight
title: foldRight — FxDart 101
description: FxDart foldRight tutorial: reduce from the last element to the first when the combining step is not associative, with a live playground.
heading: <code>foldRight</code>
section: 7
crumb: foldRight
prev: fold.html
prevLabel: fold
next: reduceLazy.html
nextLabel: reduceLazy
---
  <p class="hero-sub">Reduces from the last element to the first — the right-associative counterpart of <code>fold</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    For an associative step — <code>+</code>, <code>max</code>, string
    concatenation — direction does not matter and
    <a href="fold.html"><code>fold</code></a> is all you need. For everything
    else it decides the answer. <code>fold</code> nests from the left, so
    <code>[1, 2, 3]</code> with subtraction is
    <code>((0 - 1) - 2) - 3</code>; <code>foldRight</code> nests from the
    right and gives <code>1 - (2 - (3 - 0))</code>.
  </p>
  <p>
    The natural use is building something that <em>wraps</em>: a nested
    structure, a chain of decorators, a linked list where each step has to
    hold the rest of the result. Written as a left fold those come out
    inside-out.
  </p>
  <p>
    The reducer keeps <code>fold</code>'s <code>(acc, element)</code> argument
    order rather than Haskell's <code>foldr</code> flip, so the same callback
    works with either direction and you can switch one for the other without
    rewriting it.
  </p>
  <p>
    <code>foldRightWithIndex</code> reports each element's position in the
    <strong>source</strong>, so the last element arrives first carrying the
    highest index — the same number
    <a href="withIndex.html"><code>foldWithIndex</code></a> would give that
    element. The reversed walk is deliberately <em>not</em> renumbered 0, 1,
    2: an index that means different things in different operators is worse
    than one that counts down.
  </p>
  <p>
    Both are strict where <code>fold</code> is not. Walking backwards means
    knowing where the end is, so a source that isn't a <code>List</code> is
    materialized first and <code>foldRightAsync</code> drains the stream
    before it starts — never point it at an infinite source.
  </p>

  <h2>Demo 1 · Direction changes the answer</h2>
  {{playground:0}}

  <h2>Demo 2 · With the index, and async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: describe a pipeline as nested calls, outermost step first.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fold.html"><code>fold</code></a> — the same reduction from the left ·
    <a href="reduce.html"><code>reduce</code></a> — seeded from the first element ·
    <a href="withIndex.html"><code>foldWithIndex</code></a> — the left fold with positions ·
    <a href="reverse.html"><code>reverse</code></a> — the other way to walk backwards
  </div>
