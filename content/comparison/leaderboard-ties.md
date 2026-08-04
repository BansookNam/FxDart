---
slug: leaderboard-ties
title: Leaderboard with tied ranks — Dart vs FxDart
description: Rank players so equal scores share a rank — mutable rank/prevScore state in plain Dart vs sortBy + groupBy + zipWithIndex in FxDart.
heading: Leaderboard with tied ranks
order: 24
tier: 3
functions: sortBy, groupBy, entries, zipWithIndex, flatMap
domain: users
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Print a leaderboard from six players' scores, highest first, where
    <strong>equal scores share a rank</strong> — dense ranking, so two
    players on 87 points are both #2 and the next score down is #3.
    The data is in the code below; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Tied ranks force the native loop to carry two pieces of mutable state
    — the current <code>rank</code> and the previous score — and the tie
    rule lives in an <code>if</code> whose correctness you check by
    replaying the loop in your head. The FxDart version states the
    structure instead: <code>sortBy</code> descending,
    <code>groupBy</code> score (one group per rank), walk the groups with
    <code>entries</code> + <code>zipWithIndex</code> (group index = rank),
    and <code>flatMap</code> each group back into player lines. "Equal
    scores share a rank" stops being emergent loop behavior and becomes
    the pipeline's shape.
  </p>
