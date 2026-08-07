---
slug: share
title: share — FxDart 101
description: FxDart share tutorial: let many listeners consume one run of an event chain, and feed a LiveValue straight from a stream — with a live playground.
heading: <code>share</code> &amp; <code>LiveValue.from</code>
section: 14
crumb: share
prev: onErrorResume.html
prevLabel: onErrorResume
next: liveValue.html
nextLabel: LiveValue
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
    There is a limit worth stating plainly, because Rx's <code>share</code>
    does not have it. Rx re-subscribes when the listener count returns to
    zero and then rises again; here it <strong>cannot</strong>, because
    the upstream chain is single-subscription and there is no second run
    to give. So when the last listener leaves, the source is cancelled and
    the shared stream closes for good — a listener arriving afterwards is
    handed an already-closed stream rather than a fresh run. Attach every
    listener before the first event, or keep one alive.
  </p>
  <p>
    <code>share()</code> also does not <em>remember</em>: a listener that
    arrives after an event has passed has simply missed it. When latecomers
    need the current state — which is most UI —
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
    <a href="liveValue.html"><code>LiveValue</code></a> — the sharing that remembers: late subscribers get the current value first ·
    <a href="tee.html"><code>tee</code></a> — the pull-side answer to two readers over one pass, with no buffer ·
    <a href="fork.html"><code>fork</code></a> — two independent pull cursors over one source, at the cost of a buffer
  </div>
