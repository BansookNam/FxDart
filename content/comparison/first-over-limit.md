---
slug: first-over-limit
title: First sensor reading over the limit — Dart vs FxDart
description: Find the first temperature above a threshold — skipWhile + firstOrNull in plain Dart vs dropWhile + head in FxDart.
heading: First sensor reading over the limit
order: 10
tier: 1
functions: dropWhile, head
domain: sensors
verdict: native
async: false
---
  <h2>Requirement</h2>
  <p>
    A temperature sensor logs a reading every ten minutes. Find the
    <strong>first</strong> reading over the <strong>75.0 C</strong> limit and
    print its time and value — or a fallback line if none crossed it. The
    data is in the code below; both versions must print the line shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They don't — and here plain Dart is the honest pick. Core
    <code>skipWhile</code> plus <code>firstOrNull</code> (from
    <code>package:collection</code>) is a clean, lazy one-liner that says
    exactly what it means, with the same nullable result to handle. FxDart's
    <code>dropWhile → head</code> is the same idea under FxTS names — worth
    using if the rest of your file is already FxDart chains, but nobody
    should add a library for this line. When native Dart wins, we say so.
  </p>
