---
slug: spaceBy
title: spaceBy — FxDart 101
description: FxDart spaceBy tutorial: pace a burst without dropping any of it, shift a stream with delay, and read the newest value on a clock with sample — with a live playground.
heading: <code>delay</code>, <code>spaceBy</code> &amp; <code>sample</code>
section: 14
crumb: spaceBy
prev: groupsBy.html
prevLabel: groupsBy
next: debounceOn.html
nextLabel: debounceOn
---
  <p class="hero-sub">Three ways to move events around in time: shift them all, spread them out, or read only the newest on a fixed clock.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Rate limiting always costs you something, and the only real question
    is <em>what</em>. <code><a href="throttle.html">throttle</a></code>
    and <code><a href="debounce.html">debounce</a></code> pay in
    <strong>events</strong>: they keep one per window and drop the rest,
    which is right when the events are samples of a continuous thing and
    an old one is worthless. <code>spaceBy(gap)</code> pays in
    <strong>time</strong> instead: every event survives, queued and
    released one per <code>gap</code>, which is right when each event is a
    discrete instruction you must not lose — six messages to send against
    an API that allows one call per 100ms.
  </p>
  <p>
    That trade has a sharp edge. Because <code>spaceBy</code> queues
    rather than drops, a source that produces faster than
    <code>gap</code> forever grows an unbounded queue. It is for
    <em>bursts</em> — a batch that arrives at once and must all get
    through — not for genuinely endless input, where throttle's
    lossiness is a feature.
  </p>
  <p>
    <code>delay(duration)</code> is the simplest of the three: the entire
    stream is shifted by a fixed amount, spacing intact, nothing dropped.
    The close waits for the last delayed event to land, so nothing is
    lost at the end; errors are forwarded immediately, since only data is
    worth holding.
  </p>
  <p>
    <code>sample(period)</code> is
    <code><a href="sampleOn.html">sampleOn</a></code> with the clock built
    in — the newest value every <code>period</code>, silent when nothing
    new has arrived. Reach for it when the source is a state-like feed
    (a position, a temperature, a scroll offset) and the consumer has its
    own refresh rate. fxdart events layer, after Rx's <code>delay</code>,
    <code>interval</code> and <code>sampleTime</code>.
  </p>

  <h2>Demo 1 · Pacing a burst, losslessly</h2>
  {{playground:0}}

  <h2>Demo 2 · Shifting, and reading on a clock</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: a send rate and a reporting rate, in one chain.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="throttle.html"><code>throttle</code></a> — the lossy counterpart: one event per window, immediately ·
    <a href="debounce.html"><code>debounce</code></a> — wait for the burst to end, then take its last value ·
    <a href="chunkOn.html"><code>chunkEvery</code></a> — keep every event too, but grouped rather than spread out
  </div>
