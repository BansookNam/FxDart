---
slug: combineLatest
title: combineLatest — FxDart 101
description: FxDart combineLatest tutorial: on every event from either stream, combine the two latest values — form-validation-style derived state — with a live playground.
heading: <code>combineLatest</code>
section: 14
crumb: combineLatest
prev: sampleOn.html
prevLabel: sampleOn
next: withLatestFrom.html
nextLabel: withLatestFrom
---
  <p class="hero-sub">On every event from either side, emits <code>combine</code> of the two latest values — once both sides have spoken at least once.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A form is valid when the <em>current</em> username and the
    <em>current</em> password both pass — two streams typed independently,
    one derived state that must be right after every keystroke on either.
    <code>combineLatest(other, combine)</code> is that shape: it remembers
    the latest value of each side, and every event from <em>either</em>
    stream re-runs <code>combine</code> on the fresh pair.
  </p>
  <p>
    The rules, precisely. Nothing emits until <strong>both</strong> sides
    have produced at least one value — there is no half-initialized pair.
    After that, one event in produces exactly one event out. And a side
    that closes stops updating but its last value stays in play: the
    result only closes when <strong>both</strong> sides have closed.
  </p>
  <p>
    Choose your combinator by <em>who triggers</em>. If updates from either
    side should re-derive the state, this is your operator. If only the
    <em>source's</em> events should fire — with the other stream merely
    consulted for its latest value — that is
    <code><a href="withLatestFrom.html">withLatestFrom</a></code>.
    Contrast with the pull world's
    <code><a href="zip.html">zip</a></code>, which pairs the <em>n</em>-th
    with the <em>n</em>-th; <code>combineLatest</code> pairs newest with
    newest and never waits for indexes to line up. fxdart events layer,
    after Rx's operator of the same name.
  </p>

  <h2>Demo 1 · Form validation from two fields</h2>
  {{playground:0}}

  <h2>Demo 2 · A closed side keeps its last word</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: one display state from two sensors.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — one-sided: only source events emit ·
    <a href="zip.html"><code>zip</code></a> — index-aligned pairing in the pull world ·
    <a href="liveValue.html"><code>LiveValue</code></a> — when what you need is the current value itself
  </div>
