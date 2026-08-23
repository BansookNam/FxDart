---
slug: sampleOn
title: sampleOn — FxDart 101
description: FxDart sampleOn tutorial: emit the newest source value each time a trigger stream fires — decouple a fast producer from a slow consumer — with a live playground.
heading: <code>sampleOn</code>
section: 14
crumb: sampleOn
prev: whenComplete.html
prevLabel: whenComplete
next: combineLatest.html
nextLabel: combineLatest
---
  <p class="hero-sub">Emits the newest source value each time the trigger stream fires — the source sets the values, the trigger sets the rhythm.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A sensor updates two hundred times a second; the display repaints
    sixty. Processing every update is wasted work — what the consumer
    actually wants is <em>the newest value, on its own schedule</em>.
    <code>sampleOn(trigger)</code> is exactly that split: the source stream
    supplies values, the trigger stream supplies moments, and each trigger
    event emits the latest source value.
  </p>
  <p>
    Two details keep it honest. A trigger that fires when nothing new has
    arrived stays <strong>silent</strong> — you never see the same value
    twice in a row just because the clock ticked. And values that were
    superseded between triggers are <strong>dropped, not queued</strong>:
    this is a lossy operator by design, for state-like streams where only
    the newest reading matters.
  </p>
  <p>
    Lifetime follows the source: when the source closes, the chain closes
    and the trigger subscription is cancelled — an endless
    <code>Stream.periodic</code> tick makes a perfectly good trigger.
    Compare the neighbors: <code><a href="throttle.html">throttle</a></code>
    rate-limits with a fixed window measured from the source's own events;
    <code>sampleOn</code> hands the schedule to a second stream entirely.
    fxdart events layer, after Rx's <code>sample</code>.
  </p>

  <h2>Demo 1 · The trigger sets the rhythm</h2>
  {{playground:0}}

  <h2>Demo 2 · Silent when nothing is new, closes with the source</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: one drag position per frame.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="throttle.html"><code>throttle</code></a> — rate limiting from the source's own timing ·
    <a href="debounce.html"><code>debounce</code></a> — waiting for quiet instead of sampling ·
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — the same "latest value" idea, but combining two data streams
  </div>
