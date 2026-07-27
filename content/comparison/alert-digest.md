---
slug: alert-digest
title: Log alert digest by service and severity — Dart vs FxDart
description: WARN and ERROR logs rendered as an indented digest — nested grouping via groupBy + flatMap + uniq vs three nested loops and a seen-set.
heading: Log alert digest by service and severity
order: 38
tier: 4
functions: filter, countBy, groupBy, sortBy, flatMap, map, uniq, join
domain: logs
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    From a stream of service logs (data in the code), keep only
    <code>WARN</code> and <code>ERROR</code> lines and render an indented
    digest: services sorted by alert count, under each service the severity
    with its count, under each severity the <em>distinct</em> messages. The
    header line carries the overall ERROR/WARN totals. Both versions must
    print the digest under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    An indented digest is a tree flattened to lines, and
    <code>flatMap</code> is exactly that flattening: the outer
    <code>groupBy</code> + <code>sortBy</code> + <code>flatMap</code> emits
    a header plus its children per service, the inner <code>flatMap</code>
    does the same per severity, and <code>uniq</code> handles the repeated
    messages where they occur. <code>countBy</code> gives the header totals
    in one word. The native version is three nested <code>for</code> loops
    writing into one shared <code>body</code> list, plus a hand-rolled
    counting map and a <code>seen</code>-set for dedupe — the tree shape is
    real in both versions, but only one of them lets you read it off the
    indentation of the code itself.
  </p>
