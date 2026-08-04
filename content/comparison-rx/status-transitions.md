---
slug: status-transitions
title: Report only status changes — RxDart vs FxDart
description: Collapse a repetitive health feed to one line per run — Stream.distinct vs uniqAdjacent, with distinctUnique and uniq as the global cousins.
heading: Report only status changes
order: 15
tier: 2
functions: fx, uniqAdjacent, uniq, map
domain: logs
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A health-check feed reports <code>ok, ok, warn, warn, ok, ok, ok</code>
    — mostly repetition. Print one <em>status now</em> line per
    <strong>run</strong> (three lines), then a single
    <code>statuses seen:</code> line listing every distinct status in
    first-seen order. The data is in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Adjacent deduplication — "tell me when the value <em>changes</em>" —
    is one value of remembered state in either model, and the two sides
    are line-for-line twins. The only trap is naming, and it cuts in
    opposite directions. On the stream side, plain
    <code>Stream.distinct</code> is <em>already</em> adjacent-only —
    RxDart adds <code>distinctUnique</code> for the global version many
    people expect <code>distinct</code> to be. FxDart names it the other
    way around: <code>uniq</code> is global, like every collection
    library's <code>uniq</code>, and <code>uniqAdjacent</code> says the
    adjacent-ness out loud.
  </p>
  <p>
    Both pairs are shown above on purpose: run-collapsing with
    <code>distinct</code>&nbsp;/&nbsp;<code>uniqAdjacent</code>, the
    seen-anywhere summary with
    <code>distinctUnique</code>&nbsp;/&nbsp;<code>uniq</code>. Note what
    the global versions cost in each model — a growing "seen" set either
    way, but the stream one must hold it for the (potentially unbounded)
    life of a subscription, which is why RxDart makes the global form
    the opt-in. On a finite feed like this the models don't separate at
    all: a tie.
  </p>
