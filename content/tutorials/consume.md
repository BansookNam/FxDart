---
slug: consume
title: consume — FxDart 101
description: FxDart consume tutorial: force a lazy chain's side effects without collecting any values, with an optional limit.
heading: <code>consume</code>
section: 1
crumb: consume
prev: each.html
prevLabel: each
next: range.html
nextLabel: range
---
  <p class="hero-sub">Pulls values through a chain and throws them away — for side effects only, optionally capped.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>consume</code> is the minimal terminal operator: it pulls values
    through the chain — running whatever <code>peek</code> or
    <code>mapEffect</code> steps are upstream for their side effects — but
    discards every value instead of collecting or forwarding it. Reach for
    it when the whole point of a pipeline is its side effects, and building
    a <code>List</code> with <code>toArray</code> would just be wasted
    allocation.
  </p>
  <p>
    The optional <code>n</code> makes it the natural partner for infinite
    or huge sources: <code>consume(5)</code> pulls exactly 5 values and
    stops, even if the underlying iterable (<code>range</code> with no
    bound, <code>cycle</code>, <code>repeat</code> with a huge count) would
    otherwise go on forever. Omit <code>n</code> to drain a finite iterable
    completely.
  </p>
  <p>
    <code>consumeAsync</code> (or <code>.consume()</code> on an
    <code>FxAsync</code> chain) works the same way, awaiting each pulled
    value's side effects in turn — handy for forcing an async
    <code>peek</code>/logging pipeline to actually run without paying to
    collect a result list you'd throw away anyway.
  </p>

  <h2>Demo 1 · Bounding an infinite source</h2>
  <p>
    <code>range(1000000)</code> would normally never finish if fully pulled
    — but <code>consume(5)</code> stops after 5 elements:
  </p>
  {{playground:0}}

  <h2>Demo 2 · Async side effects, no result list</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: consume only the first 3 values of an effectively-infinite
    <code>repeat()</code>, logging each one as it's pulled.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="each.html"><code>each</code></a> — terminal op that also runs f, without the n-limit shortcut ·
    <a href="toArray.html"><code>toArray</code></a> — terminal op that collects results instead ·
    <a href="cycle.html"><code>cycle</code></a> — an infinite source consume is often paired with ·
    <a href="peek.html"><code>peek</code></a> — the lazy side-effect step consume typically forces
  </div>
