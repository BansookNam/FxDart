---
slug: stop-after-three-failures
title: Give up after three failures — RxDart vs FxDart
description: Count failures with scan and stop at the third, inclusive — one try/catch in the mapper vs turning errors into marker values before scan can see them.
heading: Give up after three failures
order: 34
tier: 3
functions: fx, toAsync, map, scan, takeUntilInclusive
domain: logs
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    A feed of ten health probes runs in order; probes 2, 5, 7, 8 and 9
    throw. Stop the run the moment the <strong>third</strong> failure is
    seen (including it), then print three counts: <em>processed</em> —
    probes that entered the pipeline before the cut; <em>failures</em> —
    how many of those threw; and <em>probes run</em> — probe bodies
    actually executed, tallied by a side-effect counter inside the probe
    itself. The later probes must never execute, so the run count has to
    match the processed count. The schedule is in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The counting core is the same on both sides — <code>scan</code> folds
    a running <code>(done, fails)</code> state, and a take-inclusive
    operator cuts the pipeline at the third failure
    (<code>takeUntilInclusive(fails == 3)</code> on one side,
    <code>takeWhileInclusive(fails &lt; 3)</code> on the other). Both
    also genuinely stop the work: <code>probes run: 7</code> proves
    that cancelling the subscription and ceasing to pull are equally
    effective brakes.
  </p>
  <p>
    The difference is what each side had to do <em>before</em> scan could
    count. A thrown probe lives on the stream's error channel, where scan
    cannot see it — and where it would end the stream at failure number
    one. So the RxDart side first converts every probe into an inner
    stream (<code>Rx.fromCallable</code> + <code>onErrorReturn(false)</code>)
    to smuggle failures back onto the data channel as marker values. The
    FxDart side needs no conversion step, because there is nothing to
    convert <em>from</em>: a try/catch inside <code>map</code> makes the
    outcome a <code>bool</code> right where it happens, and the rest of
    the pipeline is arithmetic. Same operators, one fewer model boundary
    to cross.
  </p>
