---
slug: successes-and-failures
title: Split successes from failures — RxDart vs FxDart
description: Seven async validations, two fail — a per-item try/catch feeding a typed partition vs inner streams that turn the error channel back into data.
heading: Split successes from failures
order: 26
tier: 3
functions: fx, toAsync, map, partition
domain: orders
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Seven orders from the 2026-08 import go through an async validation
    that throws for two of them (a missing shipping address, an unknown
    SKU). Keep <strong>both</strong> outcomes: print an <code>ok:</code>
    line per valid order, then the failure count. The data is in the code;
    both versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    A stream has two channels — data and error — and the error channel has
    whole-stream semantics: one thrown validation would kill the pipeline
    with five orders still unprocessed. So the RxDart side cannot simply
    <code>asyncMap(validate)</code>; it wraps <em>each</em> validation in
    its own inner stream (<code>Rx.fromCallable</code>), catches on that
    inner error channel with <code>onErrorReturnWith</code>, and re-encodes
    the failure as a data value before merging back. The recovery works,
    but it is channel plumbing: the error had to leave the data path just
    to be escorted back in.
  </p>
  <p>
    The FxDart side never puts failures on a separate channel. One
    try/catch inside <code>map</code> turns each outcome into a plain
    record — <code>(id, error?)</code> — and from there
    <code>partition</code> is an ordinary predicate split. This is the
    pull model's general stance on errors: they are <em>values</em> that
    flow through the same typed pipeline as everything else, so keeping
    successes and failures together costs nothing. When outcomes are part
    of the result rather than an interruption, the model without a
    privileged error channel has less to undo.
  </p>
