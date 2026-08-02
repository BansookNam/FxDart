---
slug: price-or-fallback
title: A price, or the list price — RxDart vs FxDart
description: A promo price where one exists, the list price where none does — per-item recovery as inner streams vs a try/catch right beside the call.
heading: A price, or the list price
order: 25
tier: 3
functions: fx, toAsync, map, ifEmpty
domain: orders
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Quote two purchase orders against the August promo price book. The
    async lookup <strong>throws</strong> for SKUs with no promo price —
    those lines must fall back to their list price, and every line must
    appear in the quote. An order with no lines quotes as the single
    line <code>(no lines to quote)</code>. The data is in the code; both
    versions must print the
    lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    A stream carries its values and its errors on <em>separate
    channels</em>, and the error channel belongs to the whole pipeline.
    By the time an <code>onErrorReturnWith</code> placed after an
    <code>asyncMap</code> saw the failure, the line that caused it would
    be gone — an error event carries the error, not the element. The
    idiomatic RxDart recovery is to give every lookup its own
    <em>inner</em> stream — <code>flatMap</code> into
    <code>Rx.fromCallable</code> — so each failure is terminal only to
    its own one-item stream, where the line is still in scope for the
    fallback.
  </p>
  <p>
    In the pull model there is no second channel to fall between. The
    lookup is an <code>await</code> inside the <code>map</code> callback,
    so recovery is ordinary Dart control flow: catch the typed
    <code>StateError</code> right beside the call and return the list
    price — the element, its fallback, and the error handling all live in
    the same four lines. No wrapping, no re-merging, and the failure
    never touches the pipeline at all.
  </p>
  <p>
    The empty second order lands the same way on both sides —
    <code>defaultIfEmpty</code>, an operator FxDart took from Rx. The
    verdict goes to FxDart for the main event: per-item error recovery is
    a sentence in the pull model and a construction in the push model.
  </p>
