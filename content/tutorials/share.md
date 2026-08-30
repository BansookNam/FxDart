---
slug: share
title: share — FxDart 101
description: FxDart share tutorial: let many listeners consume one run of an event chain, and feed a LiveValue straight from a stream — with a live playground.
heading: <code>share</code> &amp; <code>LiveValue.from</code>
section: 14
crumb: share
prev: separated.html
prevLabel: separated
next: shareReplay.html
nextLabel: shareReplay
---
  <p class="hero-sub">One run of a chain, many listeners — and the version that remembers its latest value for whoever arrives late.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Every operator in this section builds its own
    <code>StreamController</code>, so the chain it returns is
    <strong>single-subscription</strong>: listen to it twice and the
    second listener gets a <code>StateError</code>. That default is
    deliberate — it keeps the chain cold, so nothing runs until someone
    consumes it, and it keeps per-listener state honest. But it means two
    widgets cannot watch the same debounced, throttled, switch-mapped
    feed without building it twice.
  </p>
  <p>
    <code>share()</code> fixes that. It connects on the
    <strong>first</strong> listener and broadcasts to every listener from
    there, so the work upstream happens once no matter how many are
    watching. A debounce timer, a socket, an expensive map — one of each,
    not one per subscriber.
  </p>
  <p>
    <code>share({reset: true})</code> — the default — now matches Rx's
    ref-count reset. When the last listener leaves
    <strong>before the source has completed</strong>, the upstream
    subscription is cancelled and the next listener starts a fresh
    subscribe. After the source <strong>completes</strong>, a later
    listener is still handed a closed stream.
    <code>share(reset: false)</code> is the 0.8.7 behaviour: the last
    cancel closes forever. A resubscribe needs a source that allows a
    second listen — <code>Stream.fromIterable</code>,
    <code>Stream.multi</code>, <code>FxEvents.defer</code>, a
    broadcast — a spent single-subscription
    <code>StreamController</code> still cannot be re-listened. Attach
    every listener before the first event if the source is one-shot,
    or keep one alive.
  </p>
  <p>
    <code>share()</code> also does not <em>remember</em>: a listener that
    arrives after an event has passed has simply missed it. For a window
    of history, <code><a href="shareReplay.html">shareReplay</a></code>
    is the next page. When latecomers need the current state — which is
    most UI —
    <code><a href="liveValue.html">LiveValue</a></code> is the answer, and
    <code>LiveValue.from(source)</code> / <code>LiveValue.seededFrom(seed,
    source)</code> build one directly from a stream. Those are
    <strong>hot</strong>: the subscription opens immediately, so values
    arriving before anyone listens still update
    <code>value</code>, and <code>close()</code> cancels the source. They
    are named constructors rather than an optional seed so that a nullable
    <code>T</code> can still be seeded with null. fxdart events layer,
    after Rx's <code>share</code> and <code>shareValue</code>.
  </p>

  <h2>Demo 1 · Why one listener is the default</h2>
  {{playground:0}}

  <h2>Demo 2 · One run, two listeners</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: a <code>LiveValue</code> fed straight from a stream.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="shareReplay.html"><code>shareReplay</code></a> — multicast that remembers a buffer of history ·
    <a href="liveValue.html"><code>LiveValue</code></a> — the sharing that remembers: late subscribers get the current value first ·
    <a href="tee.html"><code>tee</code></a> — the pull-side answer to two readers over one pass, with no buffer ·
    <a href="fork.html"><code>fork</code></a> — two independent pull cursors over one source, at the cost of a buffer
  </div>
