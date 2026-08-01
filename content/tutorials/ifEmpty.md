---
slug: ifEmpty
title: ifEmpty — FxDart 101
description: FxDart ifEmpty and defaultIfEmpty tutorial: lazy fallbacks for pipelines that turn out empty, with a live playground.
heading: <code>ifEmpty</code>
section: 6
crumb: ifEmpty
prev: fork.html
prevLabel: fork
next: reduce.html
nextLabel: reduce
---
  <p class="hero-sub">Switches to a fallback when the pipeline turns out to be empty — decided lazily, at iteration time.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A pipeline that <em>might</em> produce nothing usually forces a
    detour: materialize it, test <code>isEmpty</code>, branch. That
    breaks the chain and — worse — runs the pipeline before you meant to.
    <code>ifEmpty(fallback)</code> folds the branch into the pipeline
    itself: values pass through untouched, and only if the source
    finishes without yielding anything does the fallback iterable take
    over. The fallback function is not even <em>called</em> otherwise —
    lazy in both directions.
  </p>
  <p>
    <code>defaultIfEmpty(value)</code> is the one-value shorthand: the
    placeholder row, the <code>0</code> for an empty report, the
    "no results" marker. Both compose anywhere in the chain, which
    matters after aggressive filtering — the emptiness is decided by
    whatever reaches this point, not by the original source.
  </p>
  <p>
    fxdart extension (no FxTS counterpart), after Rx's
    <code>switchIfEmpty</code> / <code>defaultIfEmpty</code>. The async
    forms accept an async fallback chain and a <code>Future</code>
    default, and compose with
    <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · A default for the empty report</h2>
  {{playground:0}}

  <h2>Demo 2 · Fallback source, never touched otherwise</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: search with a fallback query.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="filter.html"><code>filter</code></a> — the usual reason a chain ends up empty ·
    <a href="concat.html"><code>concat</code></a> — appending unconditionally ·
    <a href="head.html"><code>head</code></a> — <code>null</code> instead of a fallback, for a single value
  </div>
