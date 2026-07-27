---
slug: unique-tags
title: All tags across posts, sorted — Dart vs FxDart
description: Flatten post tags into one sorted, distinct list — expand + toSet + sort in plain Dart vs flatMap + uniq + sort in FxDart. An honest tie.
heading: All tags across posts, sorted
order: 14
tier: 2
functions: flatMap, uniq, sort
domain: general
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    Each blog post carries a list of tags. Build the site's tag index: flatten
    every post's tags into one sequence, drop duplicates, sort
    alphabetically, and print them as a single comma-separated line. The data
    is in the code below; both versions must print the line shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They barely do. <code>expand</code> is Dart's <code>flatMap</code>,
    <code>toSet()</code> deduplicates, and a cascade <code>..sort()</code>
    finishes the job — that one-liner is honest, idiomatic Dart and there is
    nothing wrong with it. FxDart spells the same three steps as named chain
    links (<code>flatMap → uniq → sort</code>), which reads slightly more
    like the requirement and keeps the order-preserving <code>uniq</code>
    explicit rather than a side effect of choosing a <code>Set</code>. Pick
    whichever your codebase already speaks — this one is a tie.
  </p>
