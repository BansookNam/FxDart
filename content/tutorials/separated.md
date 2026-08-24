---
slug: separated
title: rights, lefts &amp; separated — FxDart 101
description: FxDart separated tutorial: unwrap successes, unwrap failures, or split an Either event chain into both halves — with a live playground.
heading: <code>rights</code>, <code>lefts</code> &amp; <code>separated</code>
section: 14
crumb: separated
prev: mapEither.html
prevLabel: mapEither
next: share.html
nextLabel: share
---
  <p class="hero-sub">Either-aware operators on an event chain of <code>Either</code> values — unwrap one side, or split both at once.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Once a chain is <code>FxEvents&lt;Either&lt;L, R&gt;&gt;</code> —
    from <code><a href="attempt.html">attempt</a></code> or
    <code><a href="mapEither.html">mapEither</a></code> —
    these three operators are the push-side counterparts of
    <code><a href="eitherPipelines.html">FxEitherOps</a></code>.
    <code>rights()</code> keeps only the successes, unwrapped;
    <code>lefts()</code> keeps only the failures, unwrapped;
    <code>separated()</code> splits into
    <code>(failures, successes)</code> — the <code>Either</code> shape
    of <code><a href="partition.html">partition</a></code>.
  </p>
  <p>
    No terminals live here. <code>pull()</code> hands the chain to
    <code>FxAsync</code>, where <code>sequence()</code> and
    <code>flattenOrAccumulate()</code> already exist. These operators
    stay in the events layer so a UI can listen to successes and
    failures as two feeds.
  </p>
  <p>
    <code>separated()</code> inherits <code>partition</code>'s lifetime
    rules: the record is returned eagerly, listening to either side
    starts the source, cancelling both cancels it, and a value belonging
    to a side nobody listens to is dropped rather than buffered.
  </p>
  <p>
    It inherits <code>partition</code>'s error fan-out too: an error
    <em>event</em> is not an <code>Either</code>, so it goes to every
    side currently listening — one upstream failure surfaces on both
    halves. Call <code>attempt</code> upstream when a failure should be
    counted once, as a <code>Left</code> on the <code>failures</code>
    half.
  </p>

  <h2>Demo 1 · rights and lefts</h2>
  {{playground:0}}

  <h2>Demo 2 · separated splits both halves</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: an error event fans out to both halves;
    <code>attempt</code> upstream counts it once.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="eitherPipelines.html">Either × pipelines</a> — the pull-side twins, plus <code>sequence</code> and <code>flattenOrAccumulate</code> ·
    <a href="partition.html"><code>partition</code></a> — <code>separated()</code>'s predicate cousin ·
    <a href="attempt.html"><code>attempt</code></a> — convert an error event so it counts once, on the failures half
  </div>
