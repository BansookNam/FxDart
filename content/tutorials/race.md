---
slug: race
title: race — FxDart 101
description: FxDart FxEvents.race tutorial: the first stream to emit wins and every loser is cancelled immediately — cache-vs-network in one line — with a live playground.
heading: <code>race</code>
section: 14
crumb: race
prev: mergeScan.html
prevLabel: mergeScan
next: waitAll.html
nextLabel: waitAll
---
  <p class="hero-sub">The first candidate to emit wins: its whole stream is mirrored, and every other candidate is cancelled on the spot.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Ask the cache and the network at the same time; take whichever answers
    first. Try three download mirrors; keep the fastest.
    <code>FxEvents.race(candidates)</code> subscribes to every candidate at
    once, and the first <em>event</em> anywhere decides it: that event is
    delivered, and every losing candidate is <strong>cancelled
    immediately</strong> — not muted, cancelled. Their sockets close, their
    work stops, their events never happen.
  </p>
  <p>
    Be precise about what wins: the first event anywhere picks the
    winner, and from then on the race <strong>mirrors the winning stream
    in full</strong> — every later event it produces flows through, and
    the race closes when the winner closes. An <em>error</em> can win
    too: a fast broken
    endpoint beats a slow healthy one, which is exactly the honest
    behavior — you asked who answers first, and "it failed" is an answer.
    Guard slow-and-flaky fields with
    <code><a href="timeout.html">timeout</a></code>/<code><a href="retry.html">retry</a></code>
    on each candidate before racing them.
  </p>
  <p>
    Candidates that close without ever emitting drop out silently; if all
    of them do — or the candidate list is empty — the race closes empty.
    Note the direction of cancellation versus its neighbor:
    <code><a href="switchMap.html">switchMap</a></code> cancels the
    <em>older</em> of successive streams, <code>race</code> cancels the
    <em>slower</em> of simultaneous ones. fxdart events layer, after Rx's
    <code>race</code>/<code>amb</code>.
  </p>

  <h2>Demo 1 · Cache vs network, losers cancelled</h2>
  {{playground:0}}

  <h2>Demo 2 · Errors can win, empty candidates drop out</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: fastest of three mirrors.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — cancelling the older instead of the slower ·
    <a href="timeout.html"><code>timeout</code></a> — bound each candidate before the race ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>FxEvents.merge</code>, when you want everyone's events, not a winner
  </div>
