---
slug: combine-form-fields
title: Enable submit when the form is valid — RxDart vs FxDart
description: Combine the latest email and password values to drive the submit button — Rx.combineLatest2 vs combineLatest in fxdart's events layer.
heading: Enable submit when the form is valid
order: 43
tier: 4
functions: fxEvents, combineLatest
domain: users
verdict: tie
async: true
noBenchmark: timing
---
  <h2>Requirement</h2>
  <p>
    A signup form has two fields. The email field emits
    <code>nam</code>, then <code>nam@fx.dev</code>; the password field
    emits <code>hunter2</code>, then <code>box-belt-42</code> — at fixed
    interleaved offsets. After every change once both fields have
    emitted, re-evaluate the pair of latest values (valid = email
    contains <code>@</code>, password ≥ 8 chars) and print the combined
    state — three lines from the four field events, because the first
    change lands before the password has spoken; finish with the submit
    button's final state. Both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They don't. <em>Latest-value-per-source</em> state is the
    defining combinator of the push model, and both panels declare it
    in one line: hold the newest value from each field, wait until both
    have spoken, re-emit the pair on every change from either side.
    RxDart writes <code>Rx.combineLatest2(emails(), passwords(), ...)</code>;
    fxdart writes <code>fxEvents(emails()).combineLatest(passwords(),
    ...)</code>. Same waiting rule, same re-emission on either side, same
    close-when-both-close — the tagged-merge-and-fold the fxdart panel
    used to hand-roll is gone.
  </p>
  <p>
    fxdart's events layer absorbs the Rx approach for exactly
    this kind of job: a deliberate wrapper chain over plain
    <code>Stream</code>s — not an extension, so it coexists with rxdart or
    any other stream library without conflicts — carrying the latest-value
    combinators the pull pipelines cannot have. One honest caveat stands:
    RxDart's operator catalog remains far larger than fxdart's events
    layer. When the combined form state should drive typed, demand-driven
    work — a validated submit call with typed errors, say —
    <code>.pull()</code> crosses from the live pairs into the
    <code>FxAsync</code> pipeline.
  </p>
