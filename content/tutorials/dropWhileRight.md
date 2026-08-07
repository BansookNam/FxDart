---
slug: dropWhileRight
title: dropWhileRight — FxDart 101
description: FxDart dropWhileRight tutorial: trim the longest trailing run that satisfies a predicate, with a live playground.
heading: <code>dropWhileRight</code>
section: 5
crumb: dropWhileRight
prev: dropWhile.html
prevLabel: skipWhile
next: dropUntil.html
nextLabel: dropUntil
---
  <p class="hero-sub">Drops the longest run at the <em>end</em> of a source where a predicate holds — trimming a trailing run.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    This is the trim operator. Trailing zeros, trailing blank lines, a tail of
    placeholder rows — anything you want gone from the end without counting it
    first, which is all <a href="dropRight.html"><code>dropRight</code></a>
    can do.
  </p>
  <p>
    Only the run that reaches the end is dropped. A matching run in the middle
    of the source is not a suffix and stays exactly where it is — that is the
    one thing worth checking against your intuition, since
    <a href="filter.html"><code>filter</code></a> and
    <a href="reject.html"><code>reject</code></a> would have removed it.
  </p>
  <p>
    Unlike <a href="takeWhileRight.html"><code>takeWhileRight</code></a>, this
    one streams. A matching run is held back rather than emitted, because it
    might turn out to be the suffix; the first element that <em>fails</em> the
    predicate proves it was not, and releases the whole run at once. So the
    memory cost is the longest run, not the length of the source, and values
    keep flowing while the source is still open.
  </p>
  <p>
    Over a <code>List</code> the run is found by walking backwards from the
    end, so the predicate only sees that run; over any other source every
    element is tested in order. Keep the predicate pure.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, and the split</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop the trailing zeros and keep the rest.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="takeWhileRight.html"><code>takeWhileRight</code></a> — the complement: keep that same run ·
    <a href="dropRight.html"><code>dropRight</code></a> — trim a trailing slice by count ·
    <a href="dropWhile.html"><code>skipWhile</code></a> — the same idea from the front ·
    <a href="reject.html"><code>whereNot</code></a> — removes matches anywhere, not just at the end
  </div>
