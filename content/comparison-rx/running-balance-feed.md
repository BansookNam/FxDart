---
slug: running-balance-feed
title: Running balance from a deposit feed — RxDart vs FxDart
description: Fold a feed of deposits and withdrawals into a running balance — Rx scan against fxdart scan, one accumulation per movement on both sides.
heading: Running balance from a deposit feed
order: 2
tier: 1
functions: scan
domain: transactions
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    An account opens at zero and receives seven movements — deposits
    positive, withdrawals negative. Print the balance after each movement,
    one line per step. The data is in the code; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They barely do. Running state is a fold with its intermediate steps
    exposed, and both libraries call that fold <code>scan</code> — RxDart
    as a stream transformer, FxDart as a lazy operator ported from the
    same Rx lineage. One accumulation per movement, in order, on both
    sides.
  </p>
  <p>
    The visible differences are cadence details, not model differences.
    RxDart's <code>scan</code> takes a seed and emits one value per
    event (its accumulator also receives an index); FxDart's seeded
    <code>scan</code> follows FxTS and yields the seed itself first, so
    the panel uses the unseeded <code>scan1</code> — for a balance that
    opens at zero, each partial sum <em>is</em> the balance, and the two
    cadences line up exactly. Beyond that, the only residue is delivery:
    the stream version collects through an <code>async</code> main, the
    pull version is one synchronous chain. A fair tie — both sides say
    the requirement with a single operator.
  </p>
