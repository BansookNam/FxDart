---
slug: rank-labels
title: Rank labels for a leaderboard — Dart vs FxDart
description: Number a sorted leaderboard 1..n — Dart 3 indexed records vs zipWithIndex + map in FxDart.
heading: Rank labels for a leaderboard
order: 9
tier: 1
functions: zipWithIndex, map
alsoLink: fx
domain: users
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A leaderboard is already sorted by score, highest first. Print one rank
    label per player — <strong>1-based position, name, score</strong>. The
    data is in the code below; both versions must print the lines shown
    under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Only in name. Dart 3's <code>indexed</code> yields exactly the
    <code>(index, element)</code> records that FxDart's
    <code>zipWithIndex</code> does, so the two <code>map</code> callbacks
    are character-for-character identical — a clean tie, and a good example
    of Dart's core library catching up (before records and
    <code>indexed</code>, the native side was a manual counter). Use
    <code>zipWithIndex</code> when you're already inside an <code>fx</code>
    chain — it also exists on async chains — and <code>indexed</code>
    everywhere else.
  </p>
