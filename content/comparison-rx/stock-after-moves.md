---
slug: stock-after-moves
title: Stock level after each move — RxDart vs FxDart
description: Fold warehouse receipts and shipments into a running stock level and flag backorders — scan on both sides, seeds replayed differently.
heading: Stock level after each move
order: 21
tier: 2
functions: fx, scan, map
domain: orders
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A warehouse ledger for one SKU lists signed moves — positive
    receipts, negative shipments — starting from an opening stock of 20.
    Print the opening level, then each move with the level after it,
    flagging any negative level as a backorder. The moves are in the
    code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Running state is <code>scan</code> in both dialects — FxDart's is the
    FxTS port of the same Rx idea, so the fold itself is identical: an
    accumulator record carrying the move's label and the level after it.
    The one visible seam is the seed. FxDart's <code>scan</code> emits
    the seed as its first value, so the opening <code>start: 20</code>
    line falls out of the chain for free. RxDart's <code>scan</code>
    starts emitting at the first fold, so the opening level has to be
    replayed with <code>startWith</code> — one extra operator, not a
    hardship.
  </p>
  <p>
    Past the seed, the two pipelines are the same three words, and the
    flagging <code>map</code> reads equally well on either side — the
    pull version merely stays synchronous because the ledger is already
    in memory, while the stream version awaits its own delivery. Running
    state over an ordered sequence is home turf for both models: a tie,
    with the seed-emission difference as the only trivia worth
    remembering when porting between them.
  </p>
