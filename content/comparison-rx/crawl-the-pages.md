---
slug: crawl-the-pages
title: Crawl pages until exhausted — RxDart vs FxDart
description: Ask for the next page only when ready — an endless lazy cursor pulled on demand vs a big-enough Rx.range cancelled at the first empty page.
heading: Crawl pages until exhausted
order: 48
tier: 4
functions: fx, toAsync, flatMap, takeWhile, map
domain: orders
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    A paged orders API returns three orders per page and an empty list
    once the data runs out (page 4). Crawl page by page until the empty
    page, flatten the orders into one list, and print them plus how many
    pages were actually fetched — exactly four; the crawl must never
    request page 5. The fake API is in the code; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Pagination <em>is</em> the pull model: fetch a page, look at it,
    decide whether to ask for another. The FxDart side writes that down
    directly — an endless <code>sync*</code> cursor of page numbers that
    only advances when the pipeline demands the next one,
    <code>map(fetchPage)</code>, <code>takeWhile(isNotEmpty)</code>,
    flatten. Nothing bounds the cursor because demand is the bound: when
    <code>takeWhile</code> sees the empty page it simply stops pulling,
    and page 5 is never even generated.
  </p>
  <p>
    The stream side gets to the same place, but only by borrowing pull
    mechanics: an endless <code>async*</code> cursor — plain Dart rather
    than an Rx operator — <em>paused</em> into demand-driven behavior by
    <code>asyncMap</code>'s backpressure, and a <code>takeWhile</code>
    whose cancellation stops the crawl at the empty page. It works, and
    prints the same <code>pages fetched: 4</code> — because pause,
    resume and cancel are exactly the stream model's back-channel for
    simulating "ask again when ready". The pull side did not need the
    simulation: demand is its normal mode. Jobs where the consumer's
    state decides whether more input should exist are pull-shaped, and
    this is the cleanest case of it.
  </p>
