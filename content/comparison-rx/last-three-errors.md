---
slug: last-three-errors
title: The last three errors — RxDart vs FxDart
description: Keep the ERROR lines and print the last three — takeLast waits for the done event, takeRight drains the iterable; both buffer exactly three.
heading: The last three errors
order: 7
tier: 1
functions: fx, filter, takeRight
domain: logs
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    From this morning's service log, keep only the <code>ERROR</code>
    lines and print the <strong>last three</strong> of them, oldest
    first. The data is in the code; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    "The last three" has a structural cost no operator can dodge: you
    cannot know an element is among the last three until you have seen
    the end. Both sides therefore <strong>buffer</strong> — a three-slot
    window that each new error pushes into and the oldest falls out of —
    and both flush it only when the source ends. RxDart's
    <code>takeLast</code> emits nothing until the <em>done event</em>
    arrives; FxDart's <code>takeRight</code> keeps the same window while
    it drains the iterable to <em>exhaustion</em>. Same algorithm,
    keyed to each model's word for "no more elements".
  </p>
  <p>
    Upstream of that, <code>where</code> and <code>filter</code> are
    interchangeable. The one model note worth making: on an unbounded
    stream <code>takeLast</code> never emits at all — "last three" is
    only meaningful for sources that end, which is native territory for
    a finite iterable and a special case for a stream. On this bounded
    log both express the job directly, so the verdict is a tie.
  </p>
