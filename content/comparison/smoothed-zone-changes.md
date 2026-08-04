---
slug: smoothed-zone-changes
title: Smoothed zone changes — Dart vs FxDart
description: Moving average, zone runs, transition alerts — three index loops with mutable carry in plain Dart vs windowed → uniqAdjacentBy → pairwise in FxDart.
heading: Smoothed zone changes
order: 43
tier: 4
functions: windowed, average, uniqAdjacent, pairwise, ifEmpty, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A temperature sensor reports twelve raw readings per day. Smooth them
    with a <strong>3-reading moving average</strong>, classify each smoothed
    value into a zone (<code>cool</code> &lt; 20° ≤ <code>ok</code> &lt; 25°
    ≤ <code>hot</code>), and report every <strong>zone transition</strong> —
    which zone it left, which it entered, and the smoothed values on both
    sides. A day with no transitions prints a single
    <em>stable</em> line instead of nothing. The data for two July days is
    in the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Every stage of this task needs to see <em>neighboring</em> elements,
    and that is exactly where native Dart runs out of vocabulary: no
    sliding window, no adjacent-dedup, no successor pairing — in the
    standard library or in <code>package:collection</code>
    (<code>slices</code> tiles without overlap). So the native version is
    three index loops, each carrying its own mutable state: a windowed sum,
    a <code>runStarts</code> list compared against its own tail, and an
    <code>i&nbsp;-&nbsp;1</code> lookback for the transition lines, plus a
    final <code>isEmpty</code> patch-up for the stable day.
  </p>
  <p>
    The FxDart chain states the five stages in the order the data flows:
    <code>windowed(3)</code> → <code>average</code> per window,
    <code>uniqAdjacentBy(zone)</code> keeps the first smoothed value of
    each zone run, <code>pairwise</code> turns run-starts into
    (from,&nbsp;to) transitions, and <code>ifEmpty</code> supplies the
    stable-day line inside the pipeline instead of an if-check after it.
    Each fragment is independently testable, and none of it re-implements
    window bounds. These four operators are pull-model ports of the Rx
    windowing family.
  </p>
