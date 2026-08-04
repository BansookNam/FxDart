---
slug: resume-with-cache
title: Resume from cache when the source dies — RxDart vs FxDart
description: The live feed dies after three updates — onErrorResumeNext swaps in the cached tail vs an explicit pull loop feeding concat.
heading: Resume from cache when the source dies
order: 34
tier: 3
functions: fx, concat, take, map
domain: orders
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    The live order feed delivers three updates and then the connection
    dies. The dashboard still needs its first <strong>six</strong> rows:
    keep everything the live feed managed to deliver, then continue from
    last night's cached snapshot, marking those rows
    <code>(from cache)</code>. The failure is injected deterministically
    in the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    This is the error channel at its best. The recovery point is
    <em>whole-stream</em> — "when this source dies, switch to that one for
    the rest of the sequence" — which is exactly the shape a push error
    channel models. <code>onErrorResumeNext</code> says the entire
    requirement in one operator: values pass through untouched, and the
    first error swaps the subscription to the recovery stream mid-flight,
    with the three delivered updates already safely past.
  </p>
  <p>
    The pull side has no operator that keeps the values of a source that
    later throws — a pull pipeline surfaces the error at the pull site,
    and a failed <code>toList</code> would discard what came before it.
    So the boundary is written out: an <code>await for</code> loop
    collects the live rows, the <code>try</code>/<code>catch</code> names
    the failure, and <code>concat</code> + <code>map</code> +
    <code>take</code> splice on the cached tail. Two or three honest
    lines more — the same recovery, minus the vocabulary word.
  </p>
  <p>
    A toss-up, leaning RxDart on elegance here. Both
    sides stop at six rows, and neither reads the cache past what the
    page needs: <code>take</code> cancels the subscription on one side
    and simply stops pulling on the other.
  </p>
