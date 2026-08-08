---
slug: unique-tags
title: All tags across posts, sorted — Dart vs FxDart
description: Flatten post tags into one sorted, distinct list — expand + toSet + sort in plain Dart vs flatMap + uniq + sort in FxDart. A tie on the page, 1.5× on the clock.
heading: All tags across posts, sorted
order: 12
tier: 2
functions: flatMap, uniq, sort
domain: general
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    Each blog post carries a list of tags. Build the site's tag index: flatten
    every post's tags into one sequence, drop duplicates, sort
    alphabetically, and print them as a single comma-separated line. The data
    is in the code below; both versions must print the line shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    On the page, barely at all. <code>expand</code> is Dart's
    <code>flatMap</code>, <code>toSet()</code> deduplicates, and a cascade
    <code>..sort()</code> finishes the job — that chain is honest, idiomatic
    Dart and there is nothing wrong with it. FxDart spells the same three
    steps as named chain links (<code>flatMap → uniq → sort</code>), which
    reads slightly more like the requirement and keeps the order-preserving
    <code>uniq</code> explicit rather than a side effect of choosing a
    <code>Set</code>. As code, this one is a tie.
  </p>
  <p>
    The clock is not a tie. The Benchmark bars below have FxDart at
    <strong>1.47× the speed</strong> of the native chain on a million posts —
    73.5 ms against 108.0 ms — and the ratio holds all the way down (1.36× at
    N=10,000, 1.29× at N=100; those two still carry a <em>same speed</em>
    badge only because the absolute gap there is under the site's 0.6 ms
    perception floor). Both sides do identical work: three million tag
    strings pulled through a flattener, hashed into a set that keeps 500
    distinct values, then a 500-element sort. Nothing about the algorithm
    differs.
  </p>
  <p>
    The whole gap lives in one field of <code>dart:core</code>'s
    <code>ExpandIterator</code>. It seeds its inner-iterator slot with a
    <code>const EmptyIterator&lt;Never&gt;()</code> sentinel so it can defer
    the first callback, which means the hot line —
    <code>_currentExpansion!.moveNext()</code>, run once per emitted tag —
    sees <em>two</em> receiver classes over the loop's life. That is enough
    to keep AOT from inlining the inner <code>List</code> iterator, so all
    three million inner advances become indirect calls. FxDart's
    <code>flatMap</code> holds a plain <code>Iterator&lt;B&gt;?</code> that
    only ever contains the real inner iterator and uses <code>null</code> for
    "nothing open yet", so the same call site stays monomorphic and inlines.
  </p>
  <p>
    That is not a guess. Swapping <em>only</em> the flattener — FxDart's
    <code>flatMap</code> feeding native's own <code>toSet().toList()..sort()</code>
    — already lands at 78 ms; swapping only the other end, core's
    <code>expand</code> into <code>uniq</code> and <code>sort</code>, stays at
    108 ms. Hand-copying <code>ExpandIterator</code> into the benchmark and
    changing nothing but that sentinel (empty-iterator seed → <code>null</code>)
    moves it from 105 ms to 77 ms on its own; the other difference in
    shape, core's nullable <code>_current</code> read through a cast, costs
    nothing measurable. Each variant was AOT-compiled as its own binary,
    because putting them in one program makes every <code>moveNext</code> call
    site polymorphic and erases the effect being measured.
  </p>
  <p>
    Two caveats worth keeping. This is an implementation detail of the SDK,
    not a law: the day <code>ExpandIterator</code> drops that sentinel,
    <code>expand</code> matches FxDart and this page goes back to a tie in
    both columns. And a hand-written nested <code>for</code> loop that adds
    straight into a <code>Set</code> beats both, at 43 ms — dropping the
    iterator protocol entirely is still the fastest thing you can do here.
    What the measurement rules out is the assumption that reaching for a
    named pipeline costs you speed over the idiomatic core chain. Here it
    buys some.
  </p>
