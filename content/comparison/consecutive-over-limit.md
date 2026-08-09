---
slug: consecutive-over-limit
title: Three consecutive readings over the limit — Dart vs FxDart
description: Find every 3-hour window of CO2 readings all over 1000 ppm — an index loop in plain Dart vs a sliding window built from zip3 + drop in FxDart.
heading: Three consecutive readings over the limit
order: 30
tier: 3
functions: zip3, drop, filter, map, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Hourly CO2 readings for one day. Flag every window of
    <strong>three consecutive readings all above 1000 ppm</strong> —
    that means the ventilation could not catch up for three straight
    hours — and print each window as a start–end hour range under a
    header line. The data is in the code below; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Core Dart has no sliding window, so the native version is an index
    loop with an <code>i + 2 &lt; length</code> bound and three manual
    lookups — correct, but every piece of it is bookkeeping a reader must
    check. The FxDart version builds the window as <em>data</em>:
    <code>zip3</code> the list with itself shifted by one and by two
    (<code>drop(1)</code>, <code>drop(2)</code>), and each element becomes
    a (reading, next, next-next) triple — no indices anywhere.
    <code>zip3</code> stopping at the shortest input is exactly the
    window-fits-entirely rule the loop encodes as its bound. Widening the
    window to 4 hours is one more shifted input, not a re-audit of the
    arithmetic.
  </p>
  <p>
    The shifted inputs are not copies. <code>drop(n)</code> over a
    <code>List</code> is a <em>range</em> of that list, and
    <code>zip3</code> reads all three ranges by index — so the pipeline
    walks the readings once and allocates one triple per window, which is
    why its bar sits close to the loop rather than at a multiple of it.
  </p>
