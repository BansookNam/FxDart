---
slug: recent-errors
title: Recent error messages, deduped — Dart vs FxDart
description: The three most recent distinct errors from a newest-first log — a seen-Set loop with a break in plain Dart vs filter + uniqBy + take in FxDart.
heading: Recent error messages, deduped
order: 20
tier: 2
functions: filter, uniqBy, take
domain: logs
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A log store returns entries newest first. Show the <strong>three most
    recent distinct error messages</strong>: keep only <code>ERROR</code>
    entries, drop repeats of a message already shown, and stop after three.
    The data is in the code below; both versions must print the lines shown
    under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Dart has no "distinct by key" — deduping by message means managing a
    <code>Set</code> yourself, so the native version becomes a loop with
    three concerns braided together: the level check, the
    <code>seen.add</code> trick, and a counted <code>break</code>. Each is
    fine alone; together they force you to read the whole loop to see what
    it keeps. FxDart states the three rules as three chain steps —
    <code>filter</code>, <code>uniqBy</code>, <code>take</code> — and
    because the chain is lazy, it also stops scanning the log the moment the
    third distinct error is found, exactly like the hand-written
    <code>break</code>.
  </p>
