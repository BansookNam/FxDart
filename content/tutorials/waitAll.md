---
slug: waitAll
title: waitAll — FxDart 101
description: FxDart waitAll tutorial: one result once every stream has closed, plus zip, concat, combineLatestAll, mergeWith and raceWith — with a live playground.
heading: <code>waitAll</code>, <code>zip</code> &amp; friends
section: 14
crumb: waitAll
prev: race.html
prevLabel: race
next: stopOn.html
nextLabel: stopOn
---
  <p class="hero-sub">Combining many streams into one: wait for all of them, pair them up by index, play them in sequence, or let them race.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>FxEvents.waitAll(sources)</code> is
    <code>Future.wait</code> for streams. It emits exactly
    <strong>one</strong> event — a list holding each source's
    <em>last</em> value, in source order — once every source has closed,
    and then closes itself. That is the dashboard case: three panels load
    independently, and the screen renders when the slowest one is in.
    A source that closes without ever emitting means there is no complete
    result to report, so nothing is emitted at all.
  </p>
  <p>
    <code>FxEvents.zip</code> pairs sources by <strong>index</strong>:
    every source's 1st event together, then every source's 2nd, and so
    on. Whichever source runs ahead is buffered until the slowest catches
    up, and the result closes as soon as a closed source runs out of
    buffer — no further pair can ever be formed. <code>zipWith</code> is
    the two-source form, and unlike the list-based static it can pair
    <em>different</em> types.
  </p>
  <p>
    It is worth holding <code>zip</code> and
    <code><a href="combineLatest.html">combineLatest</a></code> side by
    side, because they are the two halves of "combine two streams" and
    people reach for the wrong one constantly. <strong>zip pairs by
    position</strong>: the 3rd of A always meets the 3rd of B, however
    long that takes. <strong>combineLatest pairs by time</strong>: any
    event re-emits with whatever the other side happens to hold right
    now, so one source can appear in many outputs and another in none.
    <code>combineLatestAll</code> is its N-ary form.
  </p>
  <p>
    The rest are sequencing rather than combining.
    <code>FxEvents.concat</code> plays each source through to completion
    before starting the next — <code>followedBy</code> is its two-source
    form, named after Dart's own <code>Iterable.followedBy</code>.
    <code>mergeWith</code> and <code>raceWith</code> are the instance
    forms of <code><a href="race.html">FxEvents.merge</a></code> and
    <code><a href="race.html">FxEvents.race</a></code>. fxdart events
    layer, after Rx's <code>forkJoin</code>, <code>zip</code>,
    <code>combineLatestList</code> and <code>concat</code>.
  </p>

  <h2>Demo 1 · Waiting for every panel</h2>
  {{playground:0}}

  <h2>Demo 2 · By position, or by time</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: sequencing — concat, followedBy, raceWith, mergeWith.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — the by-time pairing, and the one you usually want for UI state ·
    <a href="race.html"><code>race</code></a> — first source to speak wins, the others are cancelled ·
    <a href="zip.html"><code>zip</code></a> — the pull-layer original, pairing Iterables by index
  </div>
