---
slug: tee-the-pipeline
title: One source, two independent readers — RxDart vs FxDart
description: Total and max from one side-effecting source without running it twice — a connectable stream vs two folds advancing on the same element.
heading: One source, two independent readers
order: 48
tier: 4
functions: tee
domain: sensors
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    One reading source must feed <strong>two</strong> independent
    computations — the total and the peak — while running exactly once.
    The source increments a counter each time it runs; print the total,
    the peak, and the counter to prove the single pass. The data is in the
    code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Both models hit the same wall here: their sources restart per
    consumer. Listening to a plain single-subscription stream twice is an
    error; iterating a <code>sync*</code> generator twice quietly runs it
    twice. And both libraries answer with the same idea — share one pass.
    RxDart makes the stream <em>connectable</em>: <code>publish()</code>
    defers the source, both reductions subscribe, and <code>connect()</code>
    starts the single subscription that feeds them. FxDart's
    <code>tee</code> keeps both reductions in step instead: each element
    advances the total and the peak before the next one is pulled, so the
    single pass never has to remember anything.
  </p>
  <p>
    Both avoid a buffer, and for the same underlying reason — every
    reader sees each element while it is the current one. That is what
    <code>connect()</code> buys by making the readers attach first, and
    what <code>tee</code> buys by taking the readers as folds: a seed
    and a step, rather than two pipelines free to advance independently.
    The constraint is the price. <code>publish()</code> will feed any
    stream operators you care to subscribe; <code>tee</code> only feeds
    folds. When the two readers really are independent pipelines, FxDart's
    answer is <code>fork</code> — every fork of the same iterable object
    is a cursor over one shared, buffered pass — and there the buffer
    comes back, holding every value until the slowest cursor has consumed
    it. So this is a tie on capability: the general tool costs memory on
    both sides, and the specialised one is free on both. Pick the one
    matching the model the rest of your code already lives in.
  </p>
