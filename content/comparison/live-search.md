---
slug: live-search
title: Live search over a keystroke stream — Dart vs FxDart
description: Turn a stream of keystrokes into deduped backend searches — fromStream + filter + uniq + take + map vs await-for with guard clauses.
heading: Live search over a keystroke stream
order: 45
tier: 4
functions: streams, filter, uniq, take, map, head
alsoLink: debounce
domain: general
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    A search box emits every keystroke as a Dart <code>Stream</code> — a
    user typing toward <em>darts</em>, with some values repeated by key
    autorepeat (fixed sequence in the code below). Turn that into backend
    searches: skip queries shorter than two characters, never search the
    same query twice, stop after four searched queries, and print each
    query with its hit count and top hit — plus how many backend calls were
    actually made.
  </p>
  <p>
    With <code>fxStream</code> the keystroke stream becomes a pipeline, and
    each rule becomes an operator: <code>filter</code> for the length
    floor, <code>uniq</code> for the repeats, <code>take(4)</code> for the
    budget, then <code>map</code> performs the search. Because
    <code>take</code> sits before the search step and the chain is
    pull-based, exactly four backend calls happen and the tail of the
    stream is never consumed.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The native <code>await for</code> loop is compact — but look at where
    the rules went: the length floor and the dedupe share one
    <code>continue</code> expression (<code>q.length &lt; 2 ||
    !seen.add(q)</code>, which smuggles a mutation into a condition), and
    the budget is a counter check with a <code>break</code>. Three policies
    compressed into two guard clauses; adding a fourth means untangling
    them. The pipeline spends one named operator per rule, in the order
    they apply, and the same chain would accept a real widget's text-change
    stream unmodified. One honest caveat: fxdart's <code>debounce</code> is
    a function-call utility, not a stream operator — quieting a chatty
    stream by time is a different tool than the four rules shown here.
  </p>
