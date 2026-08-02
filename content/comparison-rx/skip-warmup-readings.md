---
slug: skip-warmup-readings
title: Skip the warm-up readings — RxDart vs FxDart
description: Drop a probe's leading low readings, keep everything after — skipWhile and dropWhile are the same one-way gate; even the operators are core.
heading: Skip the warm-up readings
order: 4
tier: 1
functions: fx, dropWhile, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A temperature probe reads low while it warms up. Drop the
    <strong>leading</strong> readings below 20.0&nbsp;°C, format everything
    after the first live reading — including later dips, which are real
    data — and print how many readings survived. The data is in the code;
    both versions must print the lines shown under <em>Expected
    output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They don't, and that is the finding. <code>skipWhile</code> and
    <code>dropWhile</code> are the same one-way gate: it discards while
    the predicate holds, opens permanently at the first failure, and
    never closes again — which is why the 18.7&nbsp;°C dip after warm-up
    survives on both sides. This is a gate over <em>sequence position</em>,
    not value, and both models have a name for it.
  </p>
  <p>
    Worth noticing: the RxDart panel is pure <code>dart:async</code> on
    this job — <code>skipWhile</code>, <code>map</code> and
    <code>toList</code> all ship on core <code>Stream</code>, so RxDart's
    import earns nothing here. That is what tier-1 overlap looks like
    from the other direction: sometimes the shared vocabulary lives in
    the platform itself. The only leftover is the delivery model — an
    <code>async</code> main and an <code>await</code> to collect what a
    pull chain returns as a plain value, no event loop involved. A tie.
  </p>
