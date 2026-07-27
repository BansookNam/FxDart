---
slug: stream-windowed-alerts
title: Windowed alerts from a sensor stream — Dart vs FxDart
description: Chunk a real Dart Stream into fixed windows and raise alerts — fromStream + chunk + averageBy vs manual buffer bookkeeping in await-for.
heading: Windowed alerts from a sensor stream
order: 44
tier: 4
functions: streams, chunk, map, averageBy, maxBy, filter
domain: sensors
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    A boiler temperature sensor delivers readings as a real Dart
    <code>Stream</code> — one every 10&nbsp;ms, twelve in total (fixed data,
    in the code below). Group the stream into <strong>windows of four
    readings</strong>, report each window's average and peak, and raise an
    <code>ALERT</code> line for any window whose average is at or above
    75.00.
  </p>
  <p>
    FxDart's answer is its stream bridge: <code>fxStream</code> lifts the
    <code>Stream</code> into the pull-based pipeline, and from there
    windowing is just <code>chunk(4)</code> — the same operator the sync
    examples use — followed by a <code>map</code> that summarizes each
    window with <code>averageBy</code> and <code>maxBy</code>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Dart's <code>Stream</code> API has no windowing operator. The idiomatic
    options are an <code>await for</code> loop with a mutable buffer —
    accumulate four, flush, reset, as shown — or packaging that same
    bookkeeping into a custom <code>StreamTransformer</code>, which is more
    code, not less. Either way the buffer, the flush condition, and the
    reset are yours to maintain, and the partial-window edge case is yours
    to reason about. In FxDart, <code>chunk(4)</code> is one word on a
    stream exactly as it is on a list — crossing from <code>Stream</code>
    to pipeline costs one <code>fxStream</code> call, and the whole
    operator vocabulary comes with it.
  </p>
