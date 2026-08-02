---
slug: stream-into-pipeline
title: A stream feeds a typed pipeline — RxDart vs FxDart
description: A live log stream flows into a typed pull pipeline through fxStream — keep the warnings, uppercase them, and count, on both sides of the bridge.
heading: A stream feeds a typed pipeline
order: 49
tier: 4
functions: fx, streams, filter, map, toList
domain: logs
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    A live log feed emits seven lines on a fixed schedule and closes. Keep
    only the warnings, uppercase them for the incident channel, and print
    them with a final count. The feed is simulated in the code (identically
    on both sides); both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They barely do — and that is the point of this pair. The source is a
    push-native thing, a <code>Stream</code> that emits when it pleases,
    and RxDart stays in that model: <code>mapNotNull</code> filters and
    formats in one operator, <code>toList</code> collects at close. Clean,
    idiomatic, done.
  </p>
  <p>
    The FxDart side does not fight the stream and does not re-model the
    source — it <em>bridges</em> it. <code>fxStream</code> wraps any
    <code>Stream</code> as a pull-based async iterable, and from that
    point on the code is the same typed chain you would write over a
    list: <code>filter</code>, <code>map</code>, <code>toList</code>. The
    bridge buffers pushed events until the pipeline demands them, so
    nothing is lost and order is preserved. This is a cooperation example,
    not a contest: let the stream be a stream at the edge where events are
    born, and cross into a pull pipeline the moment you want typed,
    demand-driven processing — the two models compose in one line. Tie,
    and deliberately so.
  </p>
