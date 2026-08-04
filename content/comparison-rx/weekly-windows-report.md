---
slug: weekly-windows-report
title: Weekly totals from a daily series — RxDart vs FxDart
description: Roll 21 days of spend into three week-numbered totals — bufferCount with scan drafted as a counter vs chunk plus zipWithIndex.
heading: Weekly totals from a daily series
order: 12
tier: 2
functions: fx, chunk, sumBy, map, zipWithIndex
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Three weeks of daily spend (August 1–21, stored in cents) roll up
    into one line per week: <code>week n: $total</code>, with the total
    converted to dollars at two decimal places. The 21 amounts are in the
    code; both versions must print the three lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The windowing itself is a wash: <code>bufferCount(7)</code> and
    <code>chunk(7)</code> are the identical idiom for the same fixed window,
    and both would emit a short trailing window if 21 didn't divide
    evenly. The job splits on <em>numbering</em> the windows. RxDart has
    no indexed operator, so the idiomatic move is to draft
    <code>scan</code> as a counter — an accumulator record whose only
    role is to carry <code>week + 1</code> alongside the buffer. It
    works, but the fold is a bystander wearing a state operator's
    clothes.
  </p>
  <p>
    The pull side has a purpose-built word: <code>zipWithIndex</code>
    pairs each chunk with its position lazily, no accumulator in sight,
    and <code>sumBy</code> folds each week's cents into dollars in the
    same breath. That is the recurring tier-2 pattern — both models
    window finite data fine, but the pull vocabulary is wider exactly
    where bookkeeping (indexes, keys, partial aggregates) meets the
    window. One repurposed operator versus one intended one: the verdict
    goes to FxDart.
  </p>
