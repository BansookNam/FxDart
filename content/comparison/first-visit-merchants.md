---
slug: first-visit-merchants
title: Merchants in first-visit order — Dart vs FxDart
description: Order-preserving dedupe — a seen-set loop in plain Dart vs map + uniq in FxDart.
heading: Merchants in first-visit order
order: 4
tier: 1
functions: map, uniq
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    From a month of transactions, list each merchant <strong>once</strong>,
    in the order it was <strong>first visited</strong> — repeat visits must
    not move a merchant later in the list. The data is in the code below;
    both versions must print the line shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The tempting native one-liner is <code>toSet().toList()</code> — and it
    would even print the right thing, because Dart's default set happens to
    be insertion-ordered. But the <code>Iterable.toSet</code> contract
    promises no order at all, so code whose <em>requirement</em> is
    first-visit order shouldn't lean on it; the honest native version is a
    seen-set loop with two collections and an <code>if</code>. FxDart's
    <code>uniq</code> makes the guarantee part of the name: it lazily keeps
    the first occurrence of each element, by contract, as one chain step
    after <code>map</code>.
  </p>
