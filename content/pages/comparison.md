---
slug: comparison
title: Dart vs FxDart — real tasks, side by side
description: 53 real-world tasks solved twice — once in plain Dart, once with FxDart — each pair runnable in the browser, with an honest verdict on which reads better.
---
  <h1>Dart vs FxDart</h1>
  <p class="hero-sub">
    The same real task, solved twice: plain Dart on the left, FxDart on the
    right. Both versions run in your browser and print exactly the same
    output — compare them and decide for yourself.
  </p>

  <p>
    A word of honesty before the list: Dart's built-in <code>Iterable</code>
    is already lazy, and simple <code>where</code>/<code>map</code> chains
    are perfectly good Dart. FxDart is not here to beat those. What it adds
    is <strong>vocabulary</strong>
    (<code><a href="../tutorials/groupBy.html">groupBy</a></code>,
    <code><a href="../tutorials/chunk.html">chunk</a></code>,
    <code><a href="../tutorials/zip.html">zip</a></code>,
    <code><a href="../tutorials/scan.html">scan</a></code>,
    <code><a href="../tutorials/uniqBy.html">uniqBy</a></code>,
    <code><a href="../tutorials/partition.html">partition</a></code> —
    things core Dart makes you hand-roll),
    <strong>composition</strong> (one typed
    <code><a href="../tutorials/fx.html">fx()</a></code> chain instead
    of nested calls and intermediate variables), and above all
    <strong>concurrency control</strong> —
    <code><a href="../tutorials/concurrent.html">.concurrent(n)</a></code> runs an
    async pipeline n items at a time, in order, which plain Dart can only
    approximate with manual worker pools. Every example carries a verdict
    badge, and some of them say native Dart is fine. That's the point: when
    an example <em>does</em> say FxDart wins, you can believe it.
  </p>

  <p>
    <span class="badge verdict-fxdart">FxDart wins</span> — clearly better here ·
    <span class="badge verdict-tie">Toss-up</span> — equally good, pick by taste ·
    <span class="badge verdict-native">Native is fine</span> — plain Dart handles it well ·
    <span class="badge badge-async">async</span> — uses async pipelines
  </p>
