---
slug: dedupe-paged-feed
title: Dedupe a paged feed by id — RxDart vs FxDart
description: Flatten three overlapping pages and keep each product id once, in arrival order — expand plus distinctUnique vs flatMap plus uniqBy.
heading: Dedupe a paged feed by id
order: 19
tier: 2
functions: fx, flatMap, uniqBy, map
domain: orders
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A product feed arrives in three pages whose boundaries overlap, so
    some items appear on two pages. Flatten the pages and print each item
    exactly once — first occurrence wins, arrival order kept — keyed by
    its numeric id. The pages are in the code; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The interesting fact is where the duplicates sit. The page boundaries
    overlap, so a repeated id arrives on a <em>different page</em> —
    never next to its first occurrence once the pages are flattened.
    That is exactly the job plain <code>Stream.distinct</code> silently
    gets wrong: it is adjacent-only, so on this feed it would wave every
    repeat straight through. The dedup here needs a whole-feed memory,
    while the flattening itself is fluent in both models —
    <code>expand</code> on the stream, <code>flatMap</code> on the pull
    chain.
  </p>
  <p>
    As in the unique-visitors pair, the global dedup is
    <code>distinctUnique</code> against <code>uniqBy</code> — an
    <code>equals</code>/<code>hashCode</code> pair versus one key
    function — and the adjacent-vs-global naming split is the one the
    status-changes page walks through. Both sides keep the same set of
    seen keys and preserve first-arrival order, so the verdict is a tie —
    the pull version just stays synchronous because the pages are
    sitting in a local list.
  </p>
