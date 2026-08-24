---
slug: eitherPipelines
title: Either × pipelines — FxDart 101
description: FxDart tutorial on typed errors fused with pipelines: rights, lefts, separated, fail-fast sequence and fail-slow mapOrAccumulate with concurrency.
heading: <code>Either</code> × pipelines
section: 13
crumb: Either × pipelines
prev: accumulate.html
prevLabel: accumulation
next: namingOfTypedErrors.html
nextLabel: the naming rationale
---
  <p class="hero-sub">
    Typed errors fused with FxDart's lazy, concurrency-aware pipelines — the
    part neither Arrow nor any Dart FP library has.
  </p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A chain of <code>Either</code> values gets Either-aware
    <em>terminals</em>: <code>rights()</code> and <code>lefts()</code> keep
    one side, <code>separated()</code> splits both at once (same record shape
    as <code>partition</code>), and <code>sequence()</code> is
    all-or-nothing — every success collected into one list, failing
    <em>fast</em> on the first <code>Left</code>. Because the pipeline is
    lazy, fail-fast is literal: <code>sequence()</code> stops <em>pulling</em>
    at the first failure, so later elements are never computed.
  </p>
  <p>
    The fail-slow twin is <code>mapOrAccumulate(transform)</code> on any
    <code>fx()</code>/async chain: validate every element, keep every
    failure. On async chains it takes <code>concurrency:&nbsp;n</code> and
    rides the same <code>concurrent(n)</code> back-channel as the rest of
    FxDart — n elements in flight, results in order, and each element runs in
    its own scope, so a failure in one can never leak into a sibling.
  </p>
  <p>
    All of these are <em>eager</em> by design, which also makes them the
    sanctioned escape from the laziness × raise hazard: never return a lazy
    pipeline from a raise block — return one of these results instead.
  </p>

  <h2>Demo 1 · rights, lefts &amp; separated</h2>
  {{playground:0}}

  <h2>Demo 2 · sequence — fail-fast, literally</h2>
  {{playground:1}}

  <h2>Demo 3 · concurrent fail-slow validation</h2>
  {{playground:2}}

  <h2>Demo 4 · flattenOrAccumulate &amp; the async extracts</h2>
  <p>
    When you already <em>have</em> the <code>Either</code>s, the fail-slow
    terminal used to be spelled
    <code>mapOrAccumulate((r,&nbsp;v)&nbsp;=&gt;&nbsp;r.bind(v))</code> — an
    identity bind. <code>flattenOrAccumulate()</code> (Arrow's name) is
    that terminal directly: every success, or <em>every</em> failure as a
    <code>Nel</code>. It completes the trio — <code>separated()</code>
    keeps both sides, <code>sequence()</code> fails fast,
    <code>flattenOrAccumulate()</code> fails slow. And the async chain now
    carries the whole extract family (<code>rights</code> /
    <code>lefts</code> / <code>separated</code> / <code>sequence</code> /
    <code>flattenOrAccumulate</code>), so an async validation feeds a
    counts badge in one terminal.
  </p>
  {{playground:4}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: sum what parsed, report what didn't.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="accumulate.html">accumulation</a> — the scope-level fail-slow vocabulary ·
    <a href="concurrent.html"><code>concurrent</code></a> — the back-channel the async variant rides ·
    <a href="partition.html"><code>partition</code></a> — <code>separated()</code>'s predicate cousin ·
    <a href="separated.html"><code>rights</code> / <code>separated</code></a> — the same extracts on an event chain ·
    <a href="typedErrors.html">typed errors — full guide</a>
  </div>
