---
slug: pipeline-into-stream
title: A pipeline feeds a stream consumer — RxDart vs FxDart
description: An ordered mapConcurrent fetch hands its results to a stream consumer via toStream — the bridge crossed in the other direction.
heading: A pipeline feeds a stream consumer
order: 47
tier: 4
functions: fx, toAsync, mapConcurrent, chunk, streams
domain: orders
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    Fetch five order statuses, at most two requests in flight, results in
    source order — then hand them to a downstream consumer that batches
    them in pairs and prints each batch. The lookup delays are fixed in
    the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    RxDart runs streams end to end: <code>flatMap</code> with
    <code>maxConcurrent: 2</code> bounds the fetches and
    <code>bufferCount(2)</code> pairs the results. One caveat lives
    in the middle: concurrent <code>flatMap</code> emits in
    <em>completion</em> order, so this panel only prints in source order
    because the delays happen to complete that way — reordering under
    concurrency is the push model's default, and keeping source order in
    general means collecting and sorting.
  </p>
  <p>
    The FxDart panel is the previous example's bridge crossed in the other
    direction. The fetching half is a pull pipeline —
    <code>mapConcurrent(2, …)</code> is ordered by construction, whatever
    the delays do — <code>chunk(2)</code> (FxDart's
    <code>bufferCount</code>) pairs the results, and <code>toStream()</code>
    hands the batches to any stream consumer. Here that consumer only
    prints, and in an RxDart app it could keep going with Rx operators on
    the bridged stream: the producer does not care who consumes. That division of labor is the
    verdict: do bounded, ordered, typed work in the pull pipeline, expose
    it as a <code>Stream</code>, and let the push world take over where
    push vocabulary (buffering, debouncing, UI binding) is the better fit.
    Tie — the bridge is the point.
  </p>
