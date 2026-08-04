---
slug: paged-feeds-dedupe
title: Two paged feeds, concatenated and deduped — Dart vs FxDart
description: Drain a primary log store, then its replica, dedupe by id, stop at 8 — concat + uniqBy + take stays lazy, vs nested loops with a seen-set.
heading: Two paged feeds, concatenated and deduped
order: 41
tier: 4
functions: range, toAsync, flatMap, concat, uniqBy, take
domain: logs
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Log events live in two paged stores — a primary and a replica whose
    pages overlap it (some events shipped to both). Fetch pages of three
    (simulated calls, fixed data in the code below), read the primary
    <em>fully first</em>, then the replica, drop events already seen (by
    id), and stop after the first <strong>eight unique events</strong>.
    Report how many of the five pages were actually fetched.
  </p>
  <p>
    To be precise about what FxDart's <code>concat</code> is: a
    <strong>sequential</strong> append, not a merge — the replica is not
    touched until the primary is exhausted. That is the right tool here,
    because the task wants primary events to win. Each store becomes an
    async sequence with <code>range</code> + <code>flatMap</code> (page
    number → page of events), and <code>uniqBy</code> + <code>take(8)</code>
    finish the job. Because the chain is pull-based, <code>take</code>
    stopping also stops the paging: the last replica page is never fetched.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The native version is three nested loops with a <code>seen</code> set
    and a labeled <code>break outer;</code> — every piece (pagination,
    ordering, dedupe, early exit) hand-woven into control flow, and the
    early exit is the part that keeps the page count at four. It works, but
    each policy lives in a guard clause rather than a name. The FxDart
    chain gives every policy its own word — <code>concat</code> for
    sequencing, <code>uniqBy</code> for dedupe, <code>take</code> for the
    budget — and the laziness that skips the fifth page is the pipeline's
    default behavior, not a carefully placed jump.
  </p>
