---
slug: anomaly-context
title: Anomalies with surrounding context — Dart vs FxDart
description: Show over-limit sensor readings plus one line before and after — zipWithIndex + flatMap + uniq as one pipeline vs an index set built in nested loops.
heading: Anomalies with surrounding context
order: 42
tier: 4
functions: zipWithIndex, filter, flatMap, uniq, map, maxBy, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A temperature sensor logged ten readings (data in the code). Print every
    reading <strong>above 80.0&nbsp;C</strong> — marked with
    <code>!</code> — together with the reading <em>directly before and
    after</em> it, the way <code>grep -C1</code> shows context lines. Where
    context windows overlap, each reading appears once. Finish with the peak
    reading. Both versions must print the block under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    "Each hit expands to a window, then overlapping windows merge" is a
    flatten-plus-dedupe problem, and FxDart spells it exactly that way:
    <code>zipWithIndex</code> keeps positions, <code>filter</code> finds the
    anomalies, <code>flatMap</code> expands each into
    <code>[i-1, i, i+1]</code>, and <code>uniq</code> merges the overlaps —
    one uninterrupted expression from readings to printed lines. Native Dart
    has no <code>flatMap</code>-into-<code>uniq</code> idiom for this, so
    the natural version builds a <code>Set&lt;int&gt;</code> of indices in
    nested <code>for</code> loops, sorts it, and formats in a second loop —
    the same algorithm, but split into three mutable phases.
  </p>
