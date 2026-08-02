---
slug: ordered-bounded-fetch
title: Fetch 4 at a time, results in order — RxDart vs FxDart
description: Eight fetches, four in flight, printed in source order — mapConcurrent is ordered by construction; flatMap(maxConcurrent) must tag and re-sort.
heading: Fetch 4 at a time, results in order
order: 35
tier: 4
functions: fx, toAsync, mapConcurrent
domain: users
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Fetch eight user profiles whose response times differ, keeping at most
    <strong>4</strong> requests in flight at once — and print the results
    in <strong>source order</strong> (user 1 first), plus the maximum
    observed in-flight count as proof of the bound. The delays are in the
    code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Both sides bound the concurrency in one operator, and the shared
    counter shows both genuinely hit 4 in flight. The split is over
    <em>order</em>. <code>flatMap(maxConcurrent: 4)</code> is a merge: it
    emits each inner result the moment it completes, so with these delays
    user 7 (10&nbsp;ms) would print before user 1 (80&nbsp;ms). To meet
    the requirement the RxDart side tags every result with its id,
    collects everything, and sorts afterwards — the ordering the source
    had is destroyed by the merge and must be rebuilt by hand at the end.
  </p>
  <p>
    <code>mapConcurrent(4, fetch)</code> never loses the order in the
    first place. In a pull pipeline, concurrency is a property of
    <em>demand</em>, not of delivery: the operator issues four overlapping
    pulls but hands results downstream in the order they were asked for,
    holding a fast late arrival until its slower predecessors are out.
    Bounded-and-ordered is the shape most batch work actually wants —
    results lined up with inputs, rate limits respected — and it is the
    default here rather than a reconstruction. When completion order is
    what you actually want, that exists too — <code>concurrentPool</code>,
    the next example — but it is the variant you opt into, not the
    behavior you undo.
  </p>
