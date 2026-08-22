---
slug: liveValue
title: LiveValue — FxDart 101
description: FxDart LiveValue tutorial: a current value with subscribers — late arrivals replay the latest value first, then live updates — with a live playground.
heading: <code>LiveValue</code>
section: 14
crumb: LiveValue
prev: share.html
prevLabel: share
next: fxSubscriptions.html
nextLabel: FxSubscriptions
---
  <p class="hero-sub">A live "current value" with subscribers: a late subscriber immediately receives the latest value, then every update after it.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A plain <code>Stream</code> has no memory: subscribe late and you get
    nothing until the next event, which for state — the current user, the
    current temperature, the current zoom — means every new screen starts
    blank. <code>LiveValue&lt;T&gt;</code> is state done as an event
    source: it holds a current value, <code>add</code> updates it and
    notifies subscribers, and every <strong>late subscriber replays the
    latest value first</strong>, then rides the live updates. No gap, no
    blank start, no "wait for the next tick".
  </p>
  <p>
    The API is deliberately small. Construct empty (<code>LiveValue()</code>)
    or with a seed (<code>LiveValue.seeded(value)</code>). Read
    synchronously with <code>.value</code> — which throws a
    <code>StateError</code> when nothing has been set, so check
    <code>.hasValue</code> or seed it; there is no silent <code>null</code>
    pretending to be state. Subscribe through <code>.live</code>, which is
    an <code><a href="fxEvents.html">FxEvents</a></code> chain (map it,
    debounce it, combine it), or <code>.stream</code> for the plain-Stream
    view of the same feed.
  </p>
  <p>
    <code>close()</code> ends the feed: subscribers' streams close, and a
    later <code>add</code> throws — though even a closed
    <code>LiveValue</code> still replays its last value to a late
    subscriber before closing their stream. If you know Rx, this is
    <code>BehaviorSubject</code> reduced to its defining behavior;
    fxdart events layer, not part of FxTS.
  </p>

  <h2>Demo 1 · Late subscribers start from the latest value</h2>
  {{playground:0}}

  <h2>Demo 2 · value, hasValue, and close</h2>
  {{playground:1}}

  <h2>Method spelling</h2>
  <p>
    A <code>Stream</code> reaches both constructors as members:
    <code>source.fxLive</code> is <code>LiveValue.from(source)</code>, and
    <code>source.fxLiveSeeded(v)</code> is
    <code>LiveValue.seededFrom(v, source)</code>. Both are still hot — the
    subscription opens on the spot.
  </p>
  <pre><code>final price = ticker.fxLive;
final count = taps.fxLiveSeeded(0);   // has a value before the first tap</code></pre>
  <h2>Try it yourself</h2>
  <p>Exercise: derive a label feed from live state.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>.live</code> speaks this chain natively ·
    <a href="combineLatest.html"><code>combineLatest</code></a> — deriving state from two live feeds ·
    <a href="streams.html">Stream bridges</a> — carrying the feed into the pull world
  </div>
