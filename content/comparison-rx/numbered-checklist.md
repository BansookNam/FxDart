---
slug: numbered-checklist
title: Number the checklist — RxDart vs FxDart
description: Turn six steps into 1.-numbered lines — streams have no indexed map, so Rx smuggles a counter through scan; fxdart says zipWithIndex.
heading: Number the checklist
order: 8
tier: 1
functions: fx, zipWithIndex, map
domain: general
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Turn six setup steps into a numbered checklist — <code>1.&nbsp;Unbox
    the sensor kit</code> and so on, one line per step, numbering from
    one. The data is in the code; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Neither core <code>Stream</code> nor RxDart has an indexed
    <code>map</code>. The closest thing RxDart offers is
    <code>scan</code>, whose accumulator happens to receive an index as
    its third argument — so the rx spelling shown numbers the steps by
    riding a <em>fold</em>: a seed you must invent (<code>''</code>) and
    an accumulated value you immediately ignore. The alternatives are no
    cleaner in kind — a mutable counter the mapper closes over, or
    zipping against <code>Rx.range</code> — every route smuggles the
    index in from outside, because no operator carries it. It works, and
    it still reads like a workaround.
  </p>
  <p>
    FxDart says the thing directly: <code>zipWithIndex</code> pairs each
    element with its position, and a plain <code>map</code> formats the
    pair. This is not a push-vs-pull gap so much as a vocabulary gap —
    an indexed pairing operator is trivially expressible in either model,
    Rx just never grew one — but the reader of each panel feels it: one
    side states "element with its index", the other encodes it in an
    accumulator's spare parameter. Verdict: FxDart.
  </p>
