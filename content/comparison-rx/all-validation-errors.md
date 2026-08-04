---
slug: all-validation-errors
title: Report every validation error — RxDart vs FxDart
description: Every rule failure per form, not just the first — plain error values in a sync chain vs an error channel that can only carry one error and then close.
heading: Report every validation error
order: 25
tier: 3
functions: fx, map, partition
alsoLink: accumulate
domain: users
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Five signup forms from the 2026-08 batch are checked against three
    rules (name present, email contains <code>@</code>, age 18+). A form
    can break <strong>several</strong> rules — report every broken rule
    per form, then list the forms that passed. The data is in the code;
    both versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Accumulating validation is the job the Rx error channel is structurally
    unable to do. A stream error carries exactly one object, and emitting
    it ends the stream — raise the first broken rule and neither the form's
    other failures nor the remaining forms are ever seen. Every recovery
    operator (<code>onErrorReturn</code>, <code>onErrorResumeNext</code>)
    is built for that one-error-then-done shape. So the working RxDart
    version shown here quietly abandons the error channel: it maps each
    form to a record of its failures on the <em>data</em> channel — at
    which point the stream is contributing an async <code>main</code> and
    a <code>toList</code>, nothing more.
  </p>
  <p>
    The FxDart side is the same idea without the wrapper: errors are plain
    values, so a synchronous <code>map</code> + <code>partition</code>
    yields the failed forms (with <em>all</em> their errors) and the valid
    ones in one expression. And because FxDart treats errors as values
    throughout, this pattern scales past records: the typed-errors layer
    accumulates for you — <code>zipOrAccumulate</code> runs every rule and
    concatenates the failures into a <code>NonEmptyList</code>, and
    <code>mapOrAccumulate</code> validates a whole collection fail-slow.
    See the <code>accumulate</code> tutorial for that full version; the
    stream model has no counterpart to reach for.
  </p>
