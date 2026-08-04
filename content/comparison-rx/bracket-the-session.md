---
slug: bracket-the-session
title: Open and close markers — RxDart vs FxDart
description: Wrap a session feed in OPEN/CLOSE lines — startWith and endWith on the stream vs prepend and append on the pull chain.
heading: Open and close markers
order: 14
tier: 2
functions: fx, prepend, append
domain: logs
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A session report lists one user's events in order, bracketed by an
    <code>== SESSION OPEN ==</code> line before the first event and an
    <code>== SESSION CLOSE ==</code> line after the last. The four events
    are in the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Almost nowhere: this is vocabulary parity. RxDart's
    <code>startWith</code> injects a value before the source's first
    emission and <code>endWith</code> injects one after the source
    completes; FxDart's <code>prepend</code> and <code>append</code> are
    the same two words on a pull chain, yielding the marker before the
    first pull reaches the source and after the source runs dry. One
    operator each, symmetric names, first-class on both sides.
  </p>
  <p>
    The only model difference worth noticing is <em>when</em> the closing
    marker can exist. On the push side <code>endWith</code> has to wait
    for the done event — the marker's position is a fact about the
    stream's lifecycle. On the pull side <code>append</code> is just the
    next thing the iterator yields once the source is exhausted; there is
    no lifecycle to observe, only demand. For a finite in-memory feed the
    distinction is invisible, so this one is a tie — pick the model the
    rest of your pipeline already lives in.
  </p>
