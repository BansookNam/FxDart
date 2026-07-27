---
slug: top-log-level
title: Most frequent log level — Dart vs FxDart
description: Count log entries per level and pick the biggest — groupListsBy + reduce in plain Dart vs countBy + maxBy in FxDart.
heading: Most frequent log level
order: 7
tier: 1
functions: countBy, maxBy
domain: logs
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Given a slice of application logs, count how many entries each
    <strong>level</strong> (INFO / WARN / ERROR) has and print the most
    frequent one with its count. The data is in the code below; both
    versions must print the line shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Native Dart has no <code>countBy</code>: the closest is
    <code>package:collection</code>'s <code>groupListsBy</code>, which builds
    a list of <em>every entry</em> per level just so you can take the
    lengths — or a hand-written <code>Map.update</code> loop. Picking the
    winner then needs a <code>reduce</code> with an explicit comparison.
    FxDart names both steps: <code>countBy</code> goes straight to the
    counts (it's terminal — it returns a plain <code>Map</code>), and
    <code>fx(counts.entries).maxBy(...)</code> re-enters the chain to pick
    the largest entry. Two named ideas instead of two hand-built ones.
  </p>
