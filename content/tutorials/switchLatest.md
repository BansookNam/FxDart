---
slug: switchLatest
title: switchLatest — FxDart 101
description: FxDart switchLatest tutorial: flatten a stream of streams by keeping only the newest inner — plus flattenMerge, flattenConcat, exhaustLatest and concatEager — with a live playground.
heading: <code>switchLatest</code>, <code>flattenMerge</code> &amp; friends
section: 14
crumb: switchLatest
prev: mergeMap.html
prevLabel: mergeMap
next: mergeScan.html
nextLabel: mergeScan
---
  <p class="hero-sub">A stream of streams, flattened: keep the newest, run them all, play them in order, or ignore the extra — and start later sources immediately with <code>concatEager</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Sometimes the events already <em>are</em> inner streams — a socket
    per session, a request already built. There is no mapper to write;
    the only question is the flattening policy. That is what these
    identity forms are:
    <code>switchLatest</code> is
    <code><a href="switchMap.html">switchMap</a>((s) =&gt; s)</code>,
    <code>flattenMerge</code> is
    <code><a href="mergeMap.html">mergeMap</a></code>,
    <code>flattenConcat</code> is <code>concatMap</code>,
    <code>exhaustLatest</code> is <code>exhaustMap</code>. An
    <code>FxEvents</code> of <code>FxEvents</code> flattens as
    <code>.map((e) =&gt; e.stream).switchLatest()</code>.
  </p>
  <p>
    <code>switchLatest</code> mirrors only the newest inner stream: a
    fresh one <strong>cancels</strong> the previous mid-flight. Use it
    when older inners become worthless — the current tab's feed, the
    current query's results. The chain closes when the outer has closed
    <em>and</em> the last inner completes.
  </p>
  <p>
    The other three are the rest of the policy table.
    <code>flattenMerge</code> runs every inner at once (cap with
    <code>concurrent: n</code>);
    <code>flattenConcat</code> plays each to completion before the next
    begins; <code>exhaustLatest</code> keeps the first and ignores
    inners that arrive while one is still running.
  </p>
  <p>
    <code>concatEager</code> is the sibling of
    <code><a href="waitAll.html">FxEvents.concat</a></code>. Both emit
    in source order, but concat waits to <em>subscribe</em> to the next
    source until the current one completes — a cold later source has
    not even started. <code>concatEager</code> subscribes to every
    source immediately and buffers later events until their turn. That
    is how you start a request now and still play the responses in
    order. fxdart events layer, after Rx's <code>switchAll</code>,
    <code>mergeAll</code>, <code>concatAll</code>,
    <code>exhaustAll</code> and <code>concatEager</code>.
  </p>

  <h2>Demo 1 · switchLatest — newest inner wins</h2>
  {{playground:0}}

  <h2>Demo 2 · flattenConcat vs switchLatest</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>concatEager</code> vs concat — later starts immediately.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — the mapped form of switchLatest ·
    <a href="mergeMap.html"><code>mergeMap</code></a> — mergeMap, concatMap, exhaustMap ·
    <a href="waitAll.html"><code>FxEvents.concat</code></a> — subscribe-later sibling of <code>concatEager</code>
  </div>
