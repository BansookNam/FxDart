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

  <h3>Why the benchmark gap is so wide</h3>
  <p>
    The bars below are not measuring laziness. At the benchmark's scale
    the first over-budget transaction sits at element 900,001 of a
    million, and <strong>both sides examine exactly 900,001</strong> —
    the checksums prove it. What the bars measure is the price of one
    element passing through each model: about <strong>1 ns</strong> on
    the pull side, about <strong>88 ns</strong> on the push side.
  </p>
  <p>
    That is not a flaw in RxDart, and it is not a spelling that a better
    operator choice fixes. We measured the alternatives on the same
    dataset — 900,001 elements, identical results:
  </p>
  <ul>
    <li><code>where().first</code> instead of <code>firstWhere</code>:
      50 ns (the fastest operator pairing we found)</li>
    <li>counting inside the predicate instead of a
      <code>doOnData</code> tap, which removes one transformer layer:
      62 ns</li>
    <li><code>await for</code> with a <code>break</code>, no operators at
      all: 227 ns — the slowest, not the fastest</li>
    <li>a hand-driven synchronous <code>StreamController</code>, which is
      no longer idiomatic Rx but is the floor for the push model:
      20 ns</li>
  </ul>
  <p>
    Even that floor is 20× the pull chain. The reason is structural. A
    <code>Stream</code> is a <em>delivery mechanism</em>: each value is
    handed to a subscription, through however many transformer layers the
    chain has, with the event-loop discipline that makes a stream safe to
    share, pause, cancel and compose across async boundaries. FxDart's
    <code>find</code> over a <code>List</code> compiles to an indexed loop
    that calls one closure per element and returns — there is no delivery,
    no subscription, no scheduling, because nothing here is actually
    asynchronous.
  </p>
  <h3>Does the trigger's position rig it?</h3>
  <p>
    Fair question, and the one thing about this case that <em>is</em> a
    judgement call. Because the search short-circuits, the dataset decides how
    much work happens: the benchmark puts the first over-budget transaction at
    90% of the way through, so a million-element run examines 900,001. Move it
    and both sides do proportionally less. If the gap were an artefact of that
    choice, moving the trigger earlier would close it.
  </p>
  <p>
    It does not. Measured back to back on an idle machine, five rounds each,
    with the 90% dataset run twice to show the noise:
  </p>
  <table>
    <thead>
      <tr>
        <th>Scale</th><th>Trigger</th><th>Examined</th>
        <th>RxDart</th><th>FxDart</th><th>Ratio</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>100</td><td>90%</td><td>91</td>
        <td>10 µs</td><td>286 ns</td><td>35×</td></tr>
      <tr><td>100</td><td>90% (repeat)</td><td>91</td>
        <td>11 µs</td><td>280 ns</td><td>39×</td></tr>
      <tr><td>100</td><td>50%</td><td>51</td>
        <td>7.5 µs</td><td>256 ns</td><td>29×</td></tr>
      <tr><td>1,000,000</td><td>90%</td><td>900,001</td>
        <td>79.1 ms</td><td>861 µs</td><td>92×</td></tr>
      <tr><td>1,000,000</td><td>90% (repeat)</td><td>900,001</td>
        <td>78.9 ms</td><td>901 µs</td><td>88×</td></tr>
      <tr><td>1,000,000</td><td>50%</td><td>500,001</td>
        <td>44.2 ms</td><td>374 µs</td><td>118×</td></tr>
    </tbody>
  </table>
  <p>
    Halving the work halves both sides — and the ratio <em>widens</em>, from
    88× to 118×. Divide the million-element rows by the elements examined and
    the reason is plain: RxDart costs <strong>87.7, 87.9 and 88.4 ns</strong>
    per element across the three runs, flat regardless of where the trigger
    sits, while FxDart costs <strong>1.00, 0.96 and 0.75 ns</strong> — the
    shorter scan is slightly cheaper per element still. An earlier trigger, if
    anything, flatters FxDart. The 100-element rows are dominated by fixed
    setup rather than per-element cost, which is why their ratios are smaller
    and noisier; that is also why the headline scale exists.
  </p>
  <p>
    So 90% is not there to inflate anything — it is there so the headline
    measures <em>pulling</em> rather than startup, and it is the least
    FxDart-favourable of the positions we tried. What the position cannot
    change is the per-element price, and that is the whole of the gap.
  </p>

  <p>
    So the honest reading of these bars is narrow: <em>when the source is
    already in memory and the question is synchronous, routing it through
    a stream is pure overhead.</em> Turn the source into something
    genuinely asynchronous — a socket, a websocket, a paginated API — and
    that per-element cost disappears under the I/O it was designed to
    manage, which is exactly the ground Part 4 covers. The code verdict
    stays a tie: both spell the same short-circuit in one operator, and
    both stop at the right moment.
  </p>
