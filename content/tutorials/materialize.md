---
slug: materialize
title: materialize — FxDart 101
description: FxDart materialize tutorial: StreamEvent (Next, Err, Done), materialize, dematerialize, timestamped, intervals, partition, and sequenceEqual — events terminal and pull sequenceEqual / sequenceEqualAsync — with a live playground.
heading: <code>materialize</code>, <code>timestamped</code>, <code>sequenceEqual</code>
section: 14
crumb: materialize
prev: fxSubscriptions.html
prevLabel: FxSubscriptions
next: job-search.html
nextLabel: debounced search
---
  <p class="hero-sub">Reify notifications as <code>Next</code> / <code>Err</code> / <code>Done</code>, stamp events with time, and test two sequences for equality.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A Dart <code>Stream</code>'s three terminals — a value, an error, a
    close — normally leave the pipe. <code>materialize</code> turns each
    into a <code>StreamEvent</code> value that can travel
    <em>through</em> the chain: a data event becomes
    <code>Next(value)</code>, an error becomes <code>Err</code> and then
    the result <strong>completes</strong> — it does not error — and a
    close becomes <code>Done</code> and then the result completes. That
    is the point of reifying them: <code>toList</code> can collect an
    error instead of failing, a log can print <code>Err(boom)</code>
    next to <code>Next(1)</code>, a test can assert the exact
    notification sequence. <code>dematerialize</code> is the inverse —
    <code>Next</code> becomes a value, <code>Err</code> becomes
    <code>Stream.addError</code>, <code>Done</code> closes the result,
    and anything after <code>Done</code> is ignored. Round-trip:
    <code>materialize().dematerialize()</code> is the original stream of
    values. fxdart events layer, after Rx's <code>materialize</code> /
    <code>dematerialize</code>.
  </p>
  <p>
    Time is the other metadata a notification can carry.
    <code>timestamped</code> pairs each event with the wall-clock time it
    arrived (<code>(DateTime at, T value)</code>);
    <code>intervals</code> pairs it with the time since the previous one
    (<code>(Duration dt, T value)</code>), and the first event is always
    <code>Duration.zero</code>. Both take <code>now:</code> so a test can
    pass a fake clock — <code>now: () =&gt; DateTime.utc(2020)</code> —
    instead of <code>DateTime.now</code>. Errors and close pass through
    unchanged. After Rx's <code>timestamp</code> and
    <code>timeInterval</code>.
  </p>
  <p>
    <code>partition(test)</code> on events is not the pull-side
    <code><a href="partition.html">partition</a></code> (which walks once
    and returns two lists). It splits one live chain into
    <code>(matches, rest)</code> sharing <strong>one</strong> run of the
    source. The record is returned eagerly; listening to either side
    starts the source; a value that belongs to a side nobody is listening
    to is dropped, not buffered. Listen to both before the source fires
    if you want both halves.
  </p>
  <p>
    <code>sequenceEqual</code> asks whether two sequences hold the same
    values in the same order and stop together. On the events layer it is
    a terminal: <code>fxEvents(a).sequenceEqual(b)</code> returns
    <code>Future&lt;bool&gt;</code>, false on the first value or length
    mismatch, and an error from either side fails the future. The same
    question exists on pull: <code>sequenceEqual</code> /
    <code>Fx.sequenceEqual</code> for iterables,
    <code>sequenceEqualAsync</code> /
    <code>FxAsync.sequenceEqual</code> for
    <code>FxAsyncIterable</code>s. After Rx's
    <code>sequenceEqual</code>.
  </p>

  <h2>Demo 1 · Next, Err, Done</h2>
  <p>
    A clean close becomes <code>Done</code>. An error becomes
    <code>Err</code> and then the chain completes — so
    <code>toList</code> returns the <code>StreamEvent</code> list instead
    of failing:
  </p>
  {{playground:0}}

  <h2>Demo 2 · A clock you can pass in</h2>
  <p>
    <code>now: () =&gt; DateTime.utc(2020)</code> keeps the stamps
    deterministic. <code>intervals</code> uses the same hook, with a
    stepping clock so the gaps are exact:
  </p>
  {{playground:1}}

  <h2>Demo 3 · sequenceEqual, and partition</h2>
  <p>
    The pull spelling is just <code>fx([1, 2]).sequenceEqual([1, 2])</code>.
    The events terminal takes a <code>Stream</code>. Listen to both
    sides of <code>partition</code> before the source runs, or the
    un-listened half is dropped:
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — the chain these operators sit on ·
    <a href="streams.html">Stream bridges</a> — four ways to pull a <code>Stream</code> into <code>FxAsync</code> ·
    <a href="partition.html"><code>partition</code></a> — the pull-side original, two lists from one walk ·
    <a href="fxSubscriptions.html"><code>FxSubscriptions</code></a> — cancel a bag of listeners together
  </div>
