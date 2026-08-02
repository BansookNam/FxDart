---
slug: withLatestFrom
title: withLatestFrom — FxDart 101
description: FxDart withLatestFrom tutorial: stamp each source event with another stream's latest value — one-sided combination for context lookups — with a live playground.
heading: <code>withLatestFrom</code>
section: 14
crumb: withLatestFrom
prev: combineLatest.html
prevLabel: combineLatest
next: switchMap.html
nextLabel: switchMap
---
  <p class="hero-sub">On every <em>source</em> event, emits <code>combine</code> of it and the other stream's latest value — the other side is context, not a trigger.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A request fires and should carry the config version that was current
    <em>at that moment</em>. An order comes in and should be priced at
    the exchange rate <em>right now</em>. Two streams are involved, but
    they are not equals: one drives, the other is consulted.
    <code>withLatestFrom(other, combine)</code> encodes that asymmetry —
    each source event emits <code>combine(event, latestOfOther)</code>,
    while events on <code>other</code> update its remembered value and
    emit <strong>nothing</strong>.
  </p>
  <p>
    That one-sidedness is the entire difference from
    <code><a href="combineLatest.html">combineLatest</a></code>, where both
    sides trigger. Pick by asking: should a config update <em>by itself</em>
    produce output? If yes, <code>combineLatest</code>; if the config only
    matters when a request happens to fire, <code>withLatestFrom</code>.
  </p>
  <p>
    Edges, honestly. Source events that fire before <code>other</code> has
    produced anything are <strong>dropped</strong> — there is no latest
    value to stamp them with (give <code>other</code> a
    <code>startWith</code> seed if that loss is wrong for you). Lifetime
    follows the source: when it closes the chain closes, and
    <code>other</code>'s close is simply ignored — a live feed on the
    context side never holds the pipeline open. fxdart events layer, after
    Rx's operator of the same name.
  </p>

  <h2>Demo 1 · Stamping requests with the current config</h2>
  {{playground:0}}

  <h2>Demo 2 · The other side never triggers, never blocks</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: price each order at the rate of its moment.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — both sides trigger ·
    <a href="sampleOn.html"><code>sampleOn</code></a> — the trigger-and-latest idea with no combining ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>startWith</code>, for seeding the context side
  </div>
