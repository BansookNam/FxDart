---
slug: conflate
title: conflate — FxDart 101
description: FxDart conflate tutorial: run an async job one at a time and keep only the newest value that arrived meanwhile — seeks, syncs, previews.
heading: <code>fxConflate</code>
section: 12
crumb: conflate
prev: onChange.html
prevLabel: onChange
next: shuffle.html
nextLabel: shuffle
---
  <p class="hero-sub">One async run at a time; whatever arrives meanwhile is collapsed to its newest value, which runs next.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A video scrubber calls <code>seekTo</code> on every drag tick, but a
    seek takes longer than a tick. Awaiting each one in turn builds a queue
    of stale seeks; firing them all at once lets an old one finish last and
    win. What the scrubber means is "go to wherever the thumb is <em>now</em>",
    and <code>fxConflate(run)</code> is that: the first call starts at once;
    a call that arrives while a run is in flight is held, and a newer call
    replaces it; when the run finishes, the held value — the newest — runs.
    Everything in between is dropped.
  </p>
  <p>
    It never waits for quiet (that is
    <a href="debounce.html"><code>fxDebounce</code></a>) and never abandons
    the run in flight (that is <code>switchLatest</code> on the events
    layer) — a <code>Future</code> cannot be cancelled, so the honest
    behaviour is to let it finish and move on. <code>.isRunning</code> and
    <code>.isPending</code> describe the state, <code>.idle</code> completes
    once nothing runs and nothing waits, and <code>.cancel()</code> drops
    the held value.
  </p>
  <p>
    An error thrown by <code>run</code> goes to <code>onError</code>, or to
    the current zone when there is none, and does not stop the next run —
    a failed sync should not block the one after it. fxdart extension (not
    part of FxTS), after Kotlin Flow's <code>conflate</code>.
  </p>

  <h2>Demo 1 · A scrubber that outruns its seek</h2>
  {{playground:0}}

  <h2>Demo 2 · State, errors and idle</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: render only the first and the newest slider value.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="debounce.html"><code>fxDebounce</code></a> — wait until calls stop ·
    <a href="throttle.html"><code>fxThrottle</code></a> — at most once per window ·
    <a href="switchLatest.html"><code>switchLatest</code></a> — the stream form, which abandons the old run ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — many runs, bounded
  </div>
