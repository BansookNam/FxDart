---
slug: cohort-retention
title: Cohort retention table — Dart vs FxDart
description: Signup-month cohorts vs later activity — nested groupBy/dropWhile/filter pipelines vs nested for loops with accumulator lists.
heading: Cohort retention table
order: 32
tier: 4
functions: groupBy, sortBy, map, dropWhile, filter, size, join
domain: users
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Each user (data in the code) has a signup month and the list of months
    they were active. Group users into <strong>cohorts by signup
    month</strong> and, for every <em>later</em> month, print what percentage
    of the cohort was still active — one row per cohort, oldest first. Both
    versions must print the table shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    A retention table is a pipeline inside a pipeline: cohorts on the
    outside, months on the inside. In FxDart both layers are expressions —
    <code>groupBy</code> → <code>sortBy</code> → <code>map</code> over
    cohorts, and inside each row <code>dropWhile</code> skips months up to
    the signup month before <code>filter</code> + <code>size</code> count the
    still-active users. The native version needs a mutable accumulator list
    per layer (<code>rows</code>, <code>cells</code>) and two nested
    <code>for</code> loops to stitch them together; the actual retention
    logic is the same, but it is spread across loop bodies instead of being
    the visible spine of the code.
  </p>
