---
slug: debounced-search
title: Debounce the search box — RxDart vs FxDart
description: Wait for the typing to go quiet before searching — debounceTime on the event stream vs the same debounce chain in fxdart 0.7.3's events layer.
heading: Debounce the search box
order: 38
tier: 4
functions: fxEvents, debounce, map
domain: users
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    A user types <code>f</code>, <code>fx</code>, <code>fxd</code> in a
    quick burst, pauses, then types <code>fxdart</code>. Search only when
    the typing has been quiet for 160&nbsp;ms — so exactly two searches
    run (<code>fxd</code> and <code>fxdart</code>) — and print each
    result. The keystroke schedule is simulated in the code; both versions
    must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They no longer do. This is a <em>push</em> problem in its purest
    form — the interesting thing is not the values but <strong>when they
    stop arriving</strong> — and both panels now say it the same way:
    debounce the event stream by 160&nbsp;ms, search each surviving query,
    collect. RxDart spells it <code>debounceTime</code>; fxdart&nbsp;0.7.3
    spells it <code>fxEvents(...).debounce(...)</code>. Operator for
    operator, the two chains are equivalent, down to the trailing value
    flushed at close.
  </p>
  <p>
    That is deliberate: fxdart's events layer absorbed the Rx approach for
    the push side. <code>fxEvents</code> is a thin wrapper chain over
    plain Dart <code>Stream</code>s — never an extension, so it collides
    with nothing, rxdart included — giving time-based operators a home the
    pull pipelines rightly refused to be. RxDart's operator catalog
    remains far larger; fxdart covers the everyday push verbs and stops.
    And when the debounced queries should feed typed, demand-driven
    work — ordered concurrent fetches, typed error handling —
    <code>.pull()</code> is the door back into the <code>FxAsync</code>
    pipeline.
  </p>
