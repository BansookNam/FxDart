---
slug: bound-the-stall
title: Bound the stalled read — RxDart vs FxDart
description: A 150 ms budget on a stalling sensor read — stream timeout watches gaps between events, pull timeout bounds demand-to-item time.
heading: Bound the stalled read
order: 30
tier: 3
functions: fx, toAsync, map, timeout
domain: sensors
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    Read four probe values in sequence; the third read stalls for
    500&nbsp;ms. Give every read a 150&nbsp;ms budget: print the readings
    that arrive in time, then <code>reading timed out</code> for the
    stall, and <strong>stop</strong> — the fourth read must not be
    reported. The stall is injected deterministically in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The per-read budget itself is easy on both sides — the RxDart panel
    bounds the <code>Future</code> inside <code>asyncMap</code>, FxDart's
    <code>timeout</code> bounds the pull — so the interesting difference
    is what each model's <em>stream-level</em> operator of the same name
    measures. <code>Stream.timeout</code> watches the gap
    <strong>between events</strong>: the producer decides when values
    arrive, so "too slow" can only mean "nothing has arrived lately".
    FxDart's <code>timeout</code> bounds <strong>demand-to-item</strong>
    time: the consumer asks, and the clock runs from the ask to the
    answer. In this finite, sequential task the two would coincide — but
    they are genuinely different quantities: a pull pipeline with no
    demand has no gaps to measure, and a push stream owes no answer to
    anyone's ask.
  </p>
  <p>
    Each side then needs one real wrinkle to meet the "then stop"
    clause. On the push side the stalled source is still out there, and
    it would resume pushing readings once the slow read finally lands —
    so after <code>onErrorReturnWith</code> converts the error into the
    report line, <code>takeWhileInclusive</code> ends the stream and
    cancels the subscription. On the pull side stopping is free — the
    <code>TimeoutException</code> simply exits the loop and nothing pulls
    again — but keeping the readings that preceded the stall means
    collecting with <code>each</code> instead of a <code>toList</code>
    that would have discarded them when it threw.
  </p>
  <p>
    A tie: one operator plus one wrinkle on each side, and the wrinkles
    are mirror images of each model's nature.
  </p>
