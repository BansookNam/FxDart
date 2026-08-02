---
slug: clean-nullable-readings
title: Drop the nulls, keep the values — RxDart vs FxDart
description: Clean a nullable sensor feed and format the survivors — whereNotNull is compact by another name, and both narrow double? to double statically.
heading: Drop the nulls, keep the values
order: 6
tier: 1
functions: fx, compact, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A battery monitor produced nine voltage samples, three of which the
    sensor dropped (<code>null</code>). Discard the failures, print each
    surviving sample formatted to one decimal, then report how many were
    dropped. The data is in the code; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    <code>whereNotNull</code> <em>is</em> <code>compact</code> — the same
    operator wearing each library's naming convention. Both do the thing
    that matters beyond filtering: they <strong>narrow the static
    type</strong>, turning a <code>double?</code> element type into
    <code>double</code>, so the <code>toStringAsFixed</code> call
    downstream needs no null checks and no <code>!</code>. Filter and
    promote in one word, on both sides.
  </p>
  <p>
    So the verdict is a tie on vocabulary — and the honest remainder is
    only the delivery model. The stream version lifts a list it already
    holds into a <code>Stream</code> and awaits the collection back out;
    the pull version finishes before the stream version's first
    <code>await</code> would have run. On a nine-element fixed list that
    overhead is small enough to shrug at, which is exactly the
    difference between this example and the verdict-carrying aggregation
    in <em>Total the valid even amounts</em>: here the point is that the
    two libraries agree, right down to the type promotion.
  </p>
