---
slug: weekly-sensor-averages
title: Weekly averages from daily readings — Dart vs FxDart
description: Fold 21 daily readings into 3 weekly averages — index arithmetic and sublist in plain Dart vs chunk + averageBy + zipWithIndex in FxDart.
heading: Weekly averages from daily readings
order: 23
tier: 3
functions: chunk, map, averageBy, zipWithIndex, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A temperature sensor logged one reading per day for three full weeks
    (21 values). Report the <strong>average per 7-day week</strong>, one
    line per week, numbered from 1. The data is in the code below; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    "Split into groups of 7" has no core-Dart spelling, so the native
    version runs a counting loop and carves each week out with
    <code>sublist(w * 7, w * 7 + 7)</code> — index arithmetic that the
    reader must re-verify, and that breaks if the tail week is short.
    FxDart's <code>chunk(7)</code> says the grouping in one word (and
    handles a short tail), <code>averageBy</code> replaces the
    reduce-then-divide dance, and <code>zipWithIndex</code> brings the week
    number into the pipeline instead of borrowing the loop counter.
  </p>
