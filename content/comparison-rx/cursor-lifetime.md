---
slug: cursor-lifetime
title: A cursor's lifetime around a read — RxDart vs FxDart
description: Open a cursor, read five rows, guarantee the close — Rx.using around a stream vs usingAsync around a lazy pull, two ports of one idea.
heading: A cursor's lifetime around a read
order: 31
tier: 3
functions: fx, using, toAsync, toList
domain: general
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    Read five ledger rows through a fake database cursor whose lifetime
    must bracket the read: created when reading starts, closed exactly
    once after the last row — and reading after close throws, so the
    bracket is load-bearing. Print the rows, then
    <code>closed:&nbsp;true</code> as the attestation. The cursor is in
    the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They mostly don't — both are ports of the same Rx idea, and FxDart
    says so: <code>usingAsync</code> (new in 0.7.2) came after Rx's
    <code>using</code>. The shape is the same three-part bracket:
    acquire, use, release. <code>Rx.using</code> creates the cursor when
    the stream is listened to and calls the disposer when the stream
    terminates; <code>usingAsync</code> acquires on the first
    <em>pull</em> and releases exactly once, after the terminal pull or
    right before an error propagates. In both, the resource's lifetime
    is tied to the consumption of the sequence, not to a scope in the
    caller — which is the whole point.
  </p>
  <p>
    The edges show each model's temperament. The stream version's
    disposer also runs on <em>unsubscription</em> — cancel halfway and
    the cursor still closes, because a subscription is an object with a
    lifecycle of its own. The pull version has no subscription: release
    fires on completion or error, so a consumer that silently
    <em>abandons</em> the iterator would never trigger it — the honest
    idiom is to bound the pipeline (<code>take</code>, or a finite
    source like this one) so completion, and therefore release, is
    guaranteed. Here the read is finite and driven to the end, and both
    sides close the cursor exactly once, after row five.
  </p>
  <p>
    A tie by design: this is the pair where the two libraries agree on
    the abstraction and differ only in what "the iteration ended" means
    in their model.
  </p>
