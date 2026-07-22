---
slug: flatMap
title: expand — FxDart 101
description: FxDart expand tutorial: map each element to an iterable and flatten one level, with a live playground.
heading: <code>expand</code>
section: 3
crumb: expand
prev: mapEffect.html
prevLabel: mapEffect
next: flat.html
nextLabel: flat
---
  <p class="hero-sub">Maps each element to an iterable, then flattens the results one level — the same contract as <code>Iterable.expand</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>expand</code> is <code>map</code> followed by one level of
    flattening: each element is turned into a <em>collection</em> of
    results, and those collections are spliced together into a single flat
    lazy sequence. It's the tool for "one input, many outputs" — splitting a
    sentence into words, expanding a user into their orders, turning a range
    into pairs. <code>expand</code> is the Dart-idiomatic name (it matches
    <a href="https://api.dart.dev/stable/dart-core/Iterable/expand.html"><code>Iterable.expand</code></a>);
    fxdart also accepts the FxTS spelling <code>flatMap</code> — they're the
    same operator.
  </p>
  <p>
    <strong>FxTS deviation:</strong> in FxTS, the callback can return any mix
    of plain values and iterables and the operator figures out what
    to flatten via <code>DeepFlat</code> type magic. Dart has no equivalent
    of that conditional type, so the Dart port requires <code>f</code> to
    <em>always</em> return an <code>Iterable&lt;B&gt;</code> — exactly like
    <a href="https://api.dart.dev/stable/dart-core/Iterable/expand.html"><code>Iterable.expand</code></a>.
    Return a single-element list (<code>[x]</code>) to emit exactly one
    value per input, or an empty list to emit none.
  </p>
  <p>
    On the async side, <code>expandAsync</code>'s internal state machine
    has to track "which sub-iterable am I currently draining" between pulls,
    so it consumes its upstream <em>serially</em> — wrapping it in
    <code>.concurrent(n)</code> only speeds up pulling already-available
    items, not an <code>await</code> that happens inside the callback
    itself. If you need concurrent async work per element, do that work in
    a <code>.map(...).concurrent(n)</code> stage first, then
    <code>.expand((list) =&gt; list)</code> to flatten the already-resolved
    lists — see Demo 2.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>The callback must return an <code>Iterable</code> — here, a 2-element
    list and a call to <code>String.split</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Async, the right way to get concurrency</h2>
  <p>
    Put the slow <code>await</code> in a <code>.map(...).concurrent(n)</code>
    stage; let <code>expand</code> flatten the results synchronously:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>expand</code> to split each sentence into words,
    producing one flat list of words.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="map.html"><code>map</code></a> — transform without flattening ·
    <a href="flat.html"><code>flat</code></a> — flatten an already-nested iterable ·
    <a href="mapEffect.html"><code>mapEffect</code></a> — map for side effects ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
