---
slug: shareReplay
title: shareReplay — FxDart 101
description: FxDart shareReplay tutorial: ReplayValue and CompletionValue, plus the connectable shareReplay that lets late listeners see history — with a live playground.
heading: <code>shareReplay</code>, <code>ReplayValue</code> &amp; <code>CompletionValue</code>
section: 14
crumb: shareReplay
prev: share.html
prevLabel: share
next: liveValue.html
nextLabel: LiveValue
---
  <p class="hero-sub">Multicast that remembers: a bounded replay buffer, a last-value-on-close, and the chain operator that wraps a source in both.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="share.html">share</a></code> broadcasts one run to
    many listeners and then forgets. A listener that arrives after an
    event has passed has missed it. <code>ReplayValue</code> is the
    subject that remembers: <code>add</code> appends to a buffer
    trimmed by <code>size</code> (default 1; <code>null</code> is
    unbounded) and <code>maxAge</code>, and every
    <strong>late subscriber replays the retained buffer first</strong>,
    then rides the live updates. Errors are not retained. After
    <code>close</code>, a late listener still gets the buffer, then
    done. fxdart events layer, after Rx's
    <code>ReplaySubject</code>.
  </p>
  <p>
    <code>CompletionValue</code> is the other memory:
    <code>add</code> only remembers, and the last value is emitted
    <strong>on close</strong> — nothing while open, then that value
    and done. A late listener after close gets the same. An
    <code>addError</code> completes immediately with the error, not a
    remembered value. Rx's <code>AsyncSubject</code>.
    <code><a href="liveValue.html">LiveValue</a></code>, next, is the
    current-value subject with a synchronous
    <code>.value</code> read — ReplayValue of size 1 without the
    getter.
  </p>
  <p>
    <code>connectable()</code> is the manual form: it returns a
    <code>ConnectableEvents</code> whose <code>events</code> feed
    does not subscribe the source until <code>connect()</code>.
    Listeners attached beforehand wait; late listeners miss already
    emitted values. <code>refCount()</code> connects on the first
    listener and disconnects on the last, reconnecting when the
    source allows a second listen. <code>shareReplay</code> is the
    usual spelling: multicast through a <code>ReplayValue</code>,
    connect on the first listener, late listeners see history.
    <code>resetOnCancel</code> (default <code>true</code>) starts a
    fresh buffer when the last listener leaves;
    <code>false</code> leaves the source connected forever.
  </p>
  <p>
    fxdart events layer, after Rx's <code>ReplaySubject</code>,
    <code>AsyncSubject</code>, <code>ConnectableObservable</code>,
    and <code>shareReplay</code>.
  </p>

  <h2>Demo 1 · A late subscriber sees the buffer</h2>
  {{playground:0}}

  <h2>Demo 2 · CompletionValue emits on close</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>shareReplay</code> on a <code>fromIterable</code>, two listeners.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="share.html"><code>share</code></a> — multicast with no memory; late listeners miss what already passed ·
    <a href="liveValue.html"><code>LiveValue</code></a> — the current-value subject, with a synchronous <code>.value</code> ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>.live</code> on these subjects is that chain
  </div>
