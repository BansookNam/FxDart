---
slug: onErrorResume
title: onErrorResume — FxDart 101
description: FxDart onErrorResume tutorial: substitute a value per error, switch to a fallback stream, or rebuild the whole stream with retry — with a live playground.
heading: <code>onErrorReturn</code>, <code>onErrorResume</code> &amp; <code>retry</code>
section: 14
crumb: onErrorResume
prev: retryOn.html
prevLabel: retryOn
next: share.html
nextLabel: share
---
  <p class="hero-sub">Three depths of recovery: patch each error with a value, abandon the source for a fallback, or throw the whole stream away and rebuild it.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Errors behave differently on the push side, and the difference trips
    people up. In a pull pipeline an exception ends the iteration — there
    is one failure and then nothing. In a Dart <code>Stream</code> an
    error is just another <strong>event</strong>: it is delivered, and the
    subscription carries on. A stream can emit ten errors and forty
    values and still close normally.
  </p>
  <p>
    That is why <code>onErrorReturn(value)</code> is a
    <em>per-error substitution</em> rather than a one-shot rescue. Every
    error becomes one <code>value</code> event and the stream keeps
    going — right for a flaky sensor where a bad reading should become a
    placeholder and the feed should survive.
  </p>
  <p>
    <code>onErrorResume(f)</code> is the one-shot switch. On the
    <strong>first</strong> error the source is cancelled outright and the
    stream <code>f</code> builds from that error takes over for good —
    the cache-on-network-failure move. Nothing more of the original
    source is ever seen, and an error thrown by <code>f</code> itself is
    forwarded rather than swallowed.
  </p>
  <p>
    <code>FxEvents.retry(factory, [count])</code> works one level up: it
    does not patch a stream's errors, it <strong>rebuilds the stream</strong>.
    On error the failed attempt is thrown away and <code>factory()</code>
    is called again for a fresh subscription — the right shape when the
    failure is the connection itself. The budget counts
    <em>re</em>-subscriptions, so <code>count: 2</code> allows at most
    three attempts; when it runs out the last error is forwarded and the
    stream closes. Events an attempt already emitted are not taken back,
    so the factory should produce something replayable.
  </p>
  <p>
    fxdart events layer, after Rx's <code>onErrorReturn</code>,
    <code>onErrorResume</code> and <code>Rx.retry</code>. For failures
    you want to <em>model</em> rather than recover from, the pull side's
    <code><a href="either.html">Either</a></code> and
    <code><a href="raise.html">Raise</a></code> make them values with
    types — see <a href="either.html">Typed errors</a>.
  </p>

  <h2>Demo 1 · A value per error</h2>
  {{playground:0}}

  <h2>Demo 2 · Abandoning the source for a fallback</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: rebuilding a flaky stream, with and without a budget.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="retry.html"><code>retry</code></a> — the pull-layer original, with a backoff hook and per-element scope ·
    <a href="either.html"><code>Either</code></a> — errors as typed values rather than events to recover from ·
    <a href="race.html"><code>race</code></a> — a candidate that errors first wins with its error
  </div>
