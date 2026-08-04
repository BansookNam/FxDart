---
slug: stop-at-shutdown
title: Take until the shutdown marker, inclusive — RxDart vs FxDart
description: Keep every event up to and including SHUTDOWN and drop the stragglers — takeWhileInclusive vs takeUntilInclusive, the same cut in two spellings.
heading: Take until the shutdown marker, inclusive
order: 22
tier: 2
functions: fx, takeUntilInclusive, map
domain: logs
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    Tonight's event feed contains a <code>SHUTDOWN</code> marker;
    everything after it belongs to the next run and must not appear in
    the report. Keep every event up to <em>and including</em> the marker
    and print each as an <code>event:</code> line. The feed is in the
    code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Plain <code>takeWhile</code> has an off-by-one problem for this job:
    the element that breaks the predicate is exactly the one you still
    want. Both libraries ship the inclusive fix, spelled from opposite
    ends — RxDart's <code>takeWhileInclusive</code> keeps going
    <em>while not the marker</em>, FxDart's <code>takeUntilInclusive</code>
    (FxTS's <code>takeUntil</code>, renamed for Dart clarity) stops
    <em>at the marker</em>. Same cut, inverted predicate.
  </p>
  <p>
    The models even agree on what happens next. After emitting the
    marker, RxDart cancels the upstream subscription, so the two
    straggler events are never delivered; FxDart simply stops pulling, so
    they are never produced. As in the budget search of Part&nbsp;1,
    cancellation and demand are the two models' words for the same
    economy — nothing downstream can tell which model was underneath.
    A tie, and a
    handy translation pair to know when moving code between the two.
  </p>
