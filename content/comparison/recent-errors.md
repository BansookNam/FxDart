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

  <h2>Two FxDart spellings</h2>
  <p>
    The benchmark on this page carries a <strong>third bar</strong>, which no
    other comparison does. The chain above is the one to write: three
    independent rules, read top to bottom, and lazy — it stops scanning at the
    third distinct error, exactly like the hand-written <code>break</code>.
    What it cannot do is inline its own callbacks. A lazy stage keeps its
    closure in an iterator field, and the AOT compiler cannot see through a
    field, so <code>filter</code> and <code>uniqBy</code> each cost a real
    indirect call on every element — together, most of what separates this
    pipeline from the native loop.
  </p>
  <p>
    <code>takeUniqBy</code>, shown above <code>main</code> in the FxDart panel,
    is the same pipeline written as one strict call. Its callback is a
    <em>parameter</em> of a body small enough to inline into the caller, so the
    compiler inlines the closure with it; one callback does both jobs, with a
    <code>null</code> key meaning "skip this element". Over 1,000,000 log lines
    that is the difference between the second and third bars — and the native
    loop is what the first bar shows.
  </p>
  <p>
    Write the chain by default. Reach for <code>takeUniqBy</code> when the
    pipeline is hot and a profile says these callbacks are the cost.
  </p>
