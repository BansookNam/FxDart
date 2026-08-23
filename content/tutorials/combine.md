---
slug: combine
title: combine — FxDart 101
description: FxDart combine tutorial: one combinator for combineLatest-style, withLatestFrom-style, zipAll and withLatestFromAll — driven by CombineSpec — with a live playground.
heading: <code>combine</code> &amp; <code>CombineSpec</code>
section: 14
crumb: combine
prev: waitAll.html
prevLabel: waitAll
next: stopOn.html
nextLabel: stopOn
---
  <p class="hero-sub">One combinator for "who triggers" and "who must have spoken" — plus <code>zipAll</code> and <code>withLatestFromAll</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="combineLatest.html">combineLatest</a></code>,
    <code><a href="withLatestFrom.html">withLatestFrom</a></code> and
    <code><a href="waitAll.html">zip</a></code> differ in who may fire
    an emit and whether every side must have spoken.
    <code>combine</code> is the unified form: a list of
    <code>CombineSpec</code>, each a <code>source</code> plus two
    flags. It is a top-level function, not
    <code>FxEvents.combine</code> — Dart cannot add statics to
    <code>FxEvents</code> from another file.
  </p>
  <p>
    <code>causesEmit: true</code> (the default) means an event from
    this source may produce an output, once every
    <code>requireFirst</code> spec has a value. All-true specs are
    <code>FxEvents.combineLatestAll</code>.
    <code>causesEmit: false</code> means this source is context only:
    it updates the slot but never fires an emit on its own — that is
    <code>withLatestFrom</code>.
    <code>requireFirst: true</code> (the default) withholds every emit
    until this source has produced at least one value;
    <code>false</code> lets the slot be <code>null</code> until it
    speaks. The result closes when every source has closed.
  </p>
  <p>
    Two more combinators live next to it.
    <code>zipAll</code> on
    <code>FxEvents&lt;Stream&lt;T&gt;&gt;</code> collects every inner
    stream until the outer completes, then zips them by index — inners
    are not even subscribed until then.
    <code>withLatestFromAll</code> is the N-ary
    <code>withLatestFrom</code>: on every source event, combine it
    with the latest of every other, dropping source events that arrive
    before every other has spoken. fxdart events layer, after Rx's
    <code>combineLatest</code> / <code>withLatestFrom</code> /
    <code>zipAll</code>.
  </p>

  <h2>Demo 1 · Both sides trigger</h2>
  {{playground:0}}

  <h2>Demo 2 · Context only — causesEmit: false</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>zipAll</code> on a stream of streams, and <code>withLatestFromAll</code> on a source.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — both sides trigger, the all-true CombineSpec ·
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — one-sided, the causesEmit: false spec ·
    <a href="waitAll.html"><code>waitAll</code></a> — zip, combineLatestAll, concat
  </div>
