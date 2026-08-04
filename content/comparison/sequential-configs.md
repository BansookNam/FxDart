---
slug: sequential-configs
title: Load three remote configs in order — Dart vs FxDart
description: Sequential async fetches — a plain await-in-loop in Dart vs toAsync + map in FxDart, one word away from bounded concurrency.
heading: Load three remote configs in order
order: 3
tier: 1
functions: toAsync, map
domain: general
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Load three remote config sections — <code>features</code>,
    <code>limits</code>, <code>theme</code> — from a (simulated) API,
    <strong>one at a time, in order</strong>, then print each loaded value.
    The fake fetch takes a fixed 15 ms; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    For three sequential awaits, the native <code>for</code> loop is
    perfectly fine — nobody needs a library to write it, and if the story
    ended here this would be a tie. The FxDart win is what the code becomes
    next: <code>toAsync().map(fetchConfig)</code> is a lazy async pipeline
    that is serial <em>by default</em>, and the day you have thirty configs
    instead of three, appending <code>.concurrent(8)</code> turns the same
    chain into a bounded worker pool — order preserved, nothing else
    touched. The native loop has no such dial; it gets rewritten. See
    <a href="bounded-concurrency.html">Fetch profiles, two at a time</a> for
    that ending.
  </p>
