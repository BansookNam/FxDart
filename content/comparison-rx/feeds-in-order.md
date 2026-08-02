---
slug: feeds-in-order
title: Two feeds, strictly in order — RxDart vs FxDart
description: Yesterday's log tail followed by today's log as one numbered list — concatWith sequencing subscriptions vs concat sequencing pulls.
heading: Two feeds, strictly in order
order: 17
tier: 2
functions: fx, concat, map
domain: logs
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    An incident review needs the tail of <strong>yesterday's</strong> log
    followed by <strong>today's</strong> log as one numbered list —
    today's first entry must never appear before yesterday's last. The
    data is in the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Both libraries write "this feed, then that one" as a single operator,
    but each model guarantees the order with its own mechanism. RxDart's
    <code>concatWith</code> is a <em>subscription</em> sequencer: it
    doesn't subscribe to today's stream until yesterday's fires
    <code>done</code>, so ordering holds even if both sources are live
    and today's would have been ready to emit earlier. FxDart's
    <code>concat</code> is a <em>demand</em> sequencer: the chain pulls
    from the second iterable only after the first is exhausted, and
    with two in-memory lists that is all the ordering there is to
    arrange.
  </p>
  <p>
    That mechanism gap matters exactly when the sources are genuinely
    push-driven — a stream that starts emitting the moment it is
    subscribed needs <code>concatWith</code>'s deferred subscription,
    where a pull pipeline would first have to buffer the not-yet-wanted
    feed. Over fixed data the two collapse into the same seven lines and
    the same <code>map</code>. A tie: the operator is shared vocabulary,
    and each model implements it with the tool it already had.
  </p>
