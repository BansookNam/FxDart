---
slug: dependent-calls-in-sequence
title: Each call feeds the next — RxDart vs FxDart
description: Four API calls where each response seeds the next request — scan threads the state through the pipeline; asyncMap closes over a mutable token.
heading: Each call feeds the next
order: 49
tier: 4
functions: fx, toAsync, map, scan
domain: general
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    Four API steps run strictly one after another — login, profile,
    orders, invoice — and each request is built from the
    <strong>previous response</strong> (the session id feeds the profile
    call, the user id feeds the orders call, …). Print each step with its
    response. The fake API table is in the code; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Neither model has to fight for sequentiality here. RxDart's
    <code>asyncMap</code> pauses the source while each future
    runs, so the calls are serial by construction; a pull pipeline only
    ever asks for the next value after the previous one resolved, so it
    is serial by default. The interesting difference is where the
    <em>dependency</em> — the token each response hands the next request —
    lives.
  </p>
  <p>
    The RxDart side threads it through a mutable variable the mapper
    closes over: idiomatic, compact, and slightly outside the pipeline —
    the data flow between steps is invisible to the operator chain. The
    FxDart side threads it through <code>scan</code>'s accumulator, so
    the previous response is an explicit input of the next step; the cost
    is that <code>scan</code> emits its seed, which the printout has to
    skip. One hidden variable versus one skipped seed line — a genuine
    tie, decided by whether you prefer state captured in a closure or
    state visible in the fold.
  </p>
