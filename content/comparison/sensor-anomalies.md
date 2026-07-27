---
slug: sensor-anomalies
title: Pair sensors with readings, keep anomalies — Dart vs FxDart
description: Join two parallel lists and flag hot readings — an index loop in plain Dart (core has no zip) vs zip + filter + map in FxDart.
heading: Pair sensors with readings, keep anomalies
order: 17
tier: 2
functions: zip, filter, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A telemetry API returns two <strong>parallel lists</strong>: sensor names
    and their latest temperature readings, matched by position. Pair them up,
    keep the readings above <strong>90.0 °C</strong>, and print one alert
    line per anomaly, in list order. The data is in the code below; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Core Dart has no <code>zip</code>. <code>package:collection</code> offers
    <code>IterableZip</code>, but it zips same-typed iterables — pairing a
    <code>List&lt;String&gt;</code> with a <code>List&lt;double&gt;</code>
    degrades both to <code>Object</code> and puts casts in your predicate —
    so in practice Dart developers write the index loop shown here instead.
    The loop is correct, but the pairing lives in positional bookkeeping
    (<code>sensors[i]</code>, <code>readings[i]</code>) and produces nothing
    you can pass along or filter further. FxDart's <code>zip</code> yields
    typed <code>(String, double)</code> record pairs, so the anomaly check
    and the formatting stay ordinary chain steps over real values.
  </p>
