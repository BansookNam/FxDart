---
slug: top-log-level
title: Most frequent log level — Dart vs FxDart
description: Count log entries per level and pick the biggest — groupListsBy + reduce in plain Dart vs countBy + maxBy in FxDart.
heading: Most frequent log level
order: 2
tier: 1
functions: countBy, maxBy
domain: logs
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Given a slice of application logs, count how many entries each
    <strong>level</strong> (INFO / WARN / ERROR) has and print the most
    frequent one with its count. The data is in the code below; both
    versions must print the line shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Native Dart has no <code>countBy</code>: the closest is
    <code>package:collection</code>'s <code>groupListsBy</code>, which builds
    a list of <em>every entry</em> per level just so you can take the
    lengths — or a hand-written <code>Map.update</code> loop. Picking the
    winner then needs a <code>reduce</code> with an explicit comparison.
    FxDart names both steps: <code>countBy</code> goes straight to the
    counts (it's terminal — it returns a plain <code>Map</code>), and
    <code>fx(counts.entries).maxBy(...)</code> re-enters the chain to pick
    the largest entry. Two named ideas instead of two hand-built ones.
  </p>

  <h2>Why the benchmark crosses over</h2>
  <p>
    The bars above are easy to misread: FxDart <em>loses</em> at N=10,000
    and <em>wins</em> at N=1,000,000. Both are real, and neither is what it
    looks like. Here is the same case swept across four scales, with the
    third implementation the section above mentions but does not chart —
    a hand-written counting loop, which is what you would write if you
    were not reaching for <code>package:collection</code> at all.
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>hand loop</th>
        <th>FxDart</th><th>vs <code>groupListsBy</code></th><th>vs hand loop</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10,000</td><td>345 µs</td><td>288 µs</td><td>415 µs</td>
        <td>1.20× slower</td><td>1.44× slower</td></tr>
      <tr><td>100,000</td><td>3.48 ms</td><td>2.87 ms</td><td>4.16 ms</td>
        <td>1.20× slower</td><td>1.45× slower</td></tr>
      <tr><td>400,000</td><td>18.7 ms</td><td>11.6 ms</td><td>16.4 ms</td>
        <td><strong>1.14× faster</strong></td><td>1.41× slower</td></tr>
      <tr><td>1,000,000</td><td>45.2 ms</td><td>28.5 ms</td><td>40.8 ms</td>
        <td><strong>1.11× faster</strong></td><td>1.43× slower</td></tr>
    </tbody>
  </table>
  <p>
    Read the last column first, because it is the one that does not move:
    against a hand-written loop FxDart is <strong>~1.4× slower at every
    scale</strong>, from ten thousand entries to a million. That is the
    honest cost of the chain — roughly 7 ns per element for the
    <code>fx()</code> wrapper and the closure dispatch through
    <code>countBy</code>. It never improves, and no amount of N makes
    FxDart's pipeline faster than a loop.
  </p>
  <p>
    So the crossover in the middle column is not FxDart speeding up. It is
    <code>groupListsBy</code> <em>slowing down</em> — and the memory
    column is where that shows:
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>hand loop</th><th>FxDart</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10,000</td><td>19.7 MB</td><td>14.7 MB</td><td>14.8 MB</td></tr>
      <tr><td>100,000</td><td>35.3 MB</td><td>16.8 MB</td><td>16.9 MB</td></tr>
      <tr><td>400,000</td><td>62.6 MB</td><td>25.8 MB</td><td>25.9 MB</td></tr>
      <tr><td>1,000,000</td><td>83.3 MB</td><td>46.9 MB</td><td>47.0 MB</td></tr>
    </tbody>
  </table>
  <p>
    <code>countBy</code> and the hand loop hold <strong>the same
    memory</strong> — within 0.1 MB at every scale — because both keep
    four integer counters and nothing else.
    <code>groupListsBy</code> materialises every one of the million
    entries into per-level <code>List</code>s just to take their lengths,
    and by N=1,000,000 that is 36 MB of garbage it has to allocate and the
    collector has to walk.
  </p>
  <p>
    That tax is also what makes it <em>erratic</em>. Across 25 samples at
    N=1,000,000, <code>groupListsBy</code> ranged 42.1–49.5 ms while
    FxDart ranged 40.3–42.2 ms. Its best run essentially ties FxDart's
    best; its median loses because it sometimes stops for a collection
    FxDart never triggers. The win above ~200,000 is the absence of
    garbage, not a faster pipeline.
  </p>
  <p>
    And the N=10,000 loss is just as honest: 415 µs against 345 µs is
    70 µs — real, but under the harness's 0.6 ms floor, which is why the
    bar above still reads <em>tie</em>. Nobody perceives 70 µs.
  </p>
  <p>
    The fair summary, then: <strong><code>countBy</code> gives you a hand
    loop's memory profile with a named operator's readability, at about
    1.4× a hand loop's time.</strong> Whether that trade is worth it is a
    judgement about your code, not a number — but it beats the idiomatic
    <code>package:collection</code> one-liner on both axes once the data
    is large, and it never costs you the 36 MB.
  </p>
  <div class="callout">
    <strong>Method:</strong> measured on the machine named in the Benchmark
    section — 5 interleaved rounds × 5 measured iterations = 25 samples per
    implementation per scale, AOT-compiled, a fresh process per sample,
    medians reported. All three implementations return an identical
    checksum at every scale.
  </div>
