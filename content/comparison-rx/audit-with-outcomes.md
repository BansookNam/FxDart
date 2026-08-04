---
slug: audit-with-outcomes
title: Keep values AND failures in the audit — RxDart vs FxDart
description: Parse eight config lines where three fail, printing the values and the failure count — errors smuggled back as data vs a plain partition.
heading: Keep values AND failures in the audit
order: 13
tier: 2
functions: fx, map, partition
domain: logs
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A deploy audit parses eight <code>key=value</code> config lines,
    three of which have unparseable values. The report needs
    <em>both</em> halves: print each successfully parsed
    <code>key = value</code>, then a count of the failures. The lines are
    in the code; both versions must print the output shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The stream model carries errors on a separate, out-of-band channel —
    and that channel is terminal: one <code>FormatException</code> ends
    the whole subscription, taking the five good lines with it. To keep
    values <em>and</em> failures, the RxDart side has to give every line
    its own inner stream (<code>Rx.fromCallable</code>) and convert the
    error into data before it can escape —
    <code>onErrorReturn(null)</code> here, with <code>null</code> standing
    in for "this one failed". That is the lightest spelling the model
    allows for a throwing function (the heavier <code>materialize</code>
    route reifies full notification objects), and it exists only to undo
    a decision the model made for you: errors were never values to begin
    with. (Both panels share the same throwing <code>parse</code> on
    purpose — with a null-returning parser both models could keep
    outcomes as plain data; the throw is the premise, and what each side
    must do about it is the comparison.)
  </p>
  <p>
    The pull side never puts failures on a channel in the first place.
    The same throw lands one local <code>try</code>/<code>catch</code>
    away from being an ordinary value again — a nullable record — so the
    whole requirement is <code>map</code> then <code>partition</code>:
    one pass, two lists, both halves equally first-class. This is the shape of FxDart's broader typed-errors
    stance (its <code>Either</code> pipelines are this same idea with
    richer error types). When failures are part of the report rather
    than an exceptional end, keeping them as data wins — the verdict
    goes to FxDart.
  </p>
