---
slug: date-window-spend
title: Spending inside a date window — Dart vs FxDart
description: Sum a slice of a date-sorted ledger — skipWhile/takeWhile/fold in plain Dart vs dropWhile + takeWhile + sumBy in FxDart. Native holds up well.
heading: Spending inside a date window
order: 18
tier: 2
functions: dropWhile, takeWhile, sumBy
alsoLink: fx
domain: transactions
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A ledger export is already <strong>sorted by date</strong>. Total the
    spending between <strong>2026-07-08 and 2026-07-21</strong> inclusive —
    without scanning the whole list: skip entries before the window, take
    entries while still inside it, and sum what remains. The data is in the
    code below; both versions must print the line shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Barely. Dart ships <code>skipWhile</code> and <code>takeWhile</code> on
    every <code>Iterable</code>, and both are lazy — the plain-Dart version
    exploits the sort order exactly the way the FxDart one does, and reads
    just as well. The only real difference is the last step:
    <code>sumBy</code> names the intent, where <code>fold</code> spells out
    the seed and the combine. That is a one-word win, not a structural one —
    call it a tie. If your codebase already chains with <code>fx</code>,
    use it here for consistency; if not, plain Dart is fine.
  </p>
