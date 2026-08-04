---
slug: first-over-budget-rx
title: First transaction over budget — RxDart vs FxDart
description: Find the first transaction over 100 and stop — Rx firstWhere cancels the subscription, fxdart find stops pulling; both examine only 4 of 8.
heading: First transaction over budget
order: 1
tier: 1
functions: fx, find
domain: transactions
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    Scan this week's card feed in arrival order and report the
    <strong>first</strong> transaction over the 100 budget — then stop
    looking. Also print how many transactions were actually examined, to
    prove the search short-circuited. The data is in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Both sides are genuinely lazy here, each in its own dialect.
    RxDart's <code>firstWhere</code> resolves its future on the first
    match and <strong>cancels the subscription</strong> — the four
    remaining transactions are never delivered. FxDart's
    <code>find</code> simply <strong>stops pulling</strong> — the four
    remaining transactions are never demanded. Cancellation and demand
    are the two models' words for the same economy, and the
    "Examined 4 of 8" line comes out identical on both sides.
  </p>
  <p>
    The instructive difference is <em>where the count lives</em>. A
    stream has a "between": <code>doOnData</code> taps the pipe between
    operators, so the rx predicate stays pure while the tap observes
    traffic. A pull chain has no between — the moment of demand is the
    predicate call itself, so the FxDart side counts inside it. Neither
    spelling is better; they are the observation idioms native to push
    and pull. Verdict: a tie — one operator each, and both stop at
    exactly the right moment.
  </p>
