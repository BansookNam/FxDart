---
slug: combine-form-fields
title: Enable submit when the form is valid — RxDart vs FxDart
description: Combine the latest email and password values to drive the submit button — Rx.combineLatest2 vs a hand-merged tagged stream folded with scan.
heading: Enable submit when the form is valid
order: 43
tier: 4
functions: fx, streams, scan, filter
domain: users
verdict: rxdart
async: true
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
    This is <em>latest-value-per-source</em> state — the defining
    combinator of the push model. <code>Rx.combineLatest2</code> holds the
    newest value from each field, waits until both have spoken, and
    re-emits the pair on every change from either side. The form logic
    reads exactly like the requirement, and the four lines of output fall
    out of one declaration.
  </p>
  <p>
    A pull pipeline consumes <em>one</em> sequence, so the FxDart side
    must first rebuild what <code>combineLatest</code> gets for free:
    merge the two fields into a single stream of tagged events
    (a hand-written controller, with its own two-subscription close
    bookkeeping), bridge it with <code>fxStream</code>, then
    <code>scan</code> the tags into a (email, password) state record and
    <code>filter</code> out states where a field has not emitted yet. The
    fold itself is honest, typed and readable — but it is a reimplementation
    of the operator, not a use of one. Reactive UI state like this is
    exactly what RxDart is for, and the verdict is RxDart's without
    argument.
  </p>
