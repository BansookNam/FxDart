---
slug: fxEvents
title: fxEvents — FxDart 101
description: FxDart fxEvents tutorial: the events layer — a chainable wrapper over plain Dart Streams, with map, where, merge, startWith, and the pull() bridge — with a live playground.
heading: <code>fxEvents</code>
section: 14
crumb: fxEvents
next: fxEventsCreate.html
nextLabel: fxEventsCreate
---
  <p class="hero-sub">Wraps a plain Dart <code>Stream</code> in a chainable <code>FxEvents</code> — the entry point to FxDart's push side.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Everything before this section is <em>pull</em>: a pipeline sits still
    until a terminal operator demands the next item. But some problems are
    genuinely <em>push</em> — keystrokes, sensor readings, socket messages
    arrive when they arrive, whether anyone asked or not. Those are what
    Dart's <code>Stream</code> models, and <code>fxEvents(stream)</code>
    gives that world the same chainable treatment: <code>map</code>,
    <code>where</code>, <code>asyncMap</code>, <code>startWith</code>,
    <code>FxEvents.merge</code> — plus the time and combination operators
    the rest of this section covers.
  </p>
  <p>
    Design decisions worth knowing. <code>FxEvents</code> is a thin
    <strong>wrapper</strong>, deliberately not a set of <code>Stream</code>
    extensions — so its operators can never collide with rxdart or any other
    stream library in the same file. The one exception is the
    <code>.fxEvents</code> entry getter, a single name nothing else claims; it
    sits beside <code>.fx</code> in
    <a href="streams.html">Stream bridges</a>. The chain stays
    <strong>cold</strong>: wrapping listens to nothing; only a terminal
    (<code>toList</code>, <code>head</code>, <code>listen</code>) starts
    events flowing. And it is
    an fxdart extension inspired by Rx, not part of FxTS — the ideas come
    from Rx, but where a name would clash with the pull layer's the pull
    spelling wins: <code>uniqAdjacent</code> rather than
    <code>distinctUntilChanged</code>, <code>stopOn</code> rather than
    <code>takeUntil</code>, <code>head</code> rather than
    <code>first</code>. One word means one thing on both sides.
  </p>
  <p>
    Two escape hatches keep you unlocked. <code>.stream</code> unwraps back
    to a plain <code>Stream</code> for any Stream-based API, at any point in
    the chain. And <code>.pull()</code> crosses into the typed pull world:
    the events become an <code><a href="toAsync.html">FxAsync</a></code>
    chain, pulled on demand from there on — push at the edge where events
    are born, pull in the core where you control demand.
  </p>

  <h2>Demo 1 · A cold chain over a Stream</h2>
  {{playground:0}}

  <h2>Demo 2 · merge, and crossing into the pull world</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: clean up a glitchy sensor feed.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="streams.html">Stream bridges</a> — the pull side of the border, and <code>stream.fx</code> vs <code>stream.fxEvents</code> side by side ·
    <a href="debounce.html"><code>debounce</code></a> &amp; <a href="throttle.html"><code>throttle</code></a> — both have <code>FxEvents</code> forms ·
    <a href="liveValue.html"><code>LiveValue</code></a> — the current-value companion to this chain
  </div>
