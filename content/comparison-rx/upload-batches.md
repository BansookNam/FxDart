---
slug: upload-batches
title: Upload in batches of 4 — RxDart vs FxDart
description: Ten pending files, at most four per request — bufferCount(4) on the stream vs chunk(4) on the pull chain, with the short last batch on both sides.
heading: Upload in batches of 4
order: 11
tier: 2
functions: fx, chunk, map
domain: orders
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    Ten files are queued for upload and the API accepts at most
    <strong>four per request</strong>. Group the queue into batches of 4
    (the last one is short) and print each batch's size and ids. The data
    is in the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Non-overlapping batching is core vocabulary in both models, and both
    say it in one word: <code>bufferCount(4)</code> collects four events
    before emitting a <code>List</code>, <code>chunk(4)</code> pulls four
    values into a <code>List</code> per demand. Both flush the short
    trailing batch when the source runs out. The <code>map</code> that
    formats each batch is then character-for-character identical.
  </p>
  <p>
    Where the models would start to diverge is just outside this
    example's frame. A stream buffers because values arrive on their own
    schedule — <code>bufferCount</code> also has time-based siblings
    (<code>bufferTime</code>) that a pull pipeline deliberately doesn't
    offer, because "what arrived in the last second" has no meaning when
    the consumer controls arrival. A pull chain chunks because the
    <em>consumer</em> wants four-at-a-time demand — which is also why
    <code>chunk</code> composes directly with downstream concurrency
    (send each batch while assembling the next). For a fixed queue of
    ten, neither advantage is exercised: a tie.
  </p>
