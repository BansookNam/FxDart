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

  <h2>Where the time actually goes</h2>
  <p>
    Counting is almost pure hash-map work, so this case is really a
    measurement of how many times each element touches the map. Broken down
    by cost per element at N=1,000,000:
  </p>
  <table>
    <thead>
      <tr><th>what the loop does</th><th>ns per element</th></tr>
    </thead>
    <tbody>
      <tr><td>walk the list</td><td>0.3</td></tr>
      <tr><td>+ load the <code>.level</code> field</td><td>0.7</td></tr>
      <tr><td>+ hash it</td><td>1.7</td></tr>
      <tr><td>+ count with a <code>switch</code> into four locals</td><td>12.5</td></tr>
      <tr><td>+ <strong>one</strong> map probe</td><td>20.9</td></tr>
      <tr><td>+ <strong>two</strong> map probes</td><td>29.3</td></tr>
    </tbody>
  </table>
  <p>
    Traversal and the key extractor are free — under 1 ns between them. The
    map is everything. And the obvious hand-written line,
    <code>counts[k] = (counts[k] ?? 0) + 1</code>, probes the map
    <em>twice</em>: once to read, once to write back. That second probe is
    about 30% of the runtime, and it is the reason a named operator can beat
    the loop you would have written. Since 0.8.4 <code>countBy</code> counts
    into a mutable cell parked in the map, so the read hands back the cell and
    the increment goes through that reference — the map is written once per
    <em>distinct level</em> instead of once per entry.
  </p>

  <h2>Why the benchmark crosses over</h2>
  <p>
    Here is the same case swept across four scales, with the third
    implementation the section above mentions but does not chart — a
    hand-written counting loop, which is what you would write if you were not
    reaching for <code>package:collection</code> at all.
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>hand loop</th>
        <th>FxDart</th><th>vs <code>groupListsBy</code></th><th>vs hand loop</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10,000</td><td>351 µs</td><td>291 µs</td><td>199 µs</td>
        <td><strong>1.76× faster</strong></td><td><strong>1.46× faster</strong></td></tr>
      <tr><td>100,000</td><td>3.6 ms</td><td>2.9 ms</td><td>2.0 ms</td>
        <td><strong>1.83× faster</strong></td><td><strong>1.47× faster</strong></td></tr>
      <tr><td>400,000</td><td>18.2 ms</td><td>11.6 ms</td><td>7.8 ms</td>
        <td><strong>2.32× faster</strong></td><td><strong>1.48× faster</strong></td></tr>
      <tr><td>1,000,000</td><td>44.5 ms</td><td>28.8 ms</td><td>19.4 ms</td>
        <td><strong>2.30× faster</strong></td><td><strong>1.48× faster</strong></td></tr>
    </tbody>
  </table>
  <p>
    Read the last column first, because it is the one that does not move:
    against a hand-written loop FxDart is <strong>~1.47× faster at every
    scale</strong>, from ten thousand entries to a million. That constant is
    the single map probe from the section above — the operator can afford a
    trick that is too fiddly to be worth hand-writing, and it pays the same
    dividend at every N.
  </p>
  <div class="callout">
    <strong>This page used to say the opposite.</strong> Before 0.8.4,
    <code>countBy</code> did the same two probes as the loop <em>plus</em> the
    chain's overhead, and the honest number here was ~1.4× <em>slower</em> at
    every scale. Only the FxDart column moved: re-measured on the same
    machine, <code>groupListsBy</code> and the hand loop land within 2% of
    their old figures.
  </div>
  <p>
    The <code>groupListsBy</code> column widens on top of that, and the
    memory column is where that shows:
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>hand loop</th><th>FxDart</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10,000</td><td>18.8 MB</td><td>14.1 MB</td><td>14.2 MB</td></tr>
      <tr><td>100,000</td><td>33.8 MB</td><td>16.1 MB</td><td>16.2 MB</td></tr>
      <tr><td>400,000</td><td>59.8 MB</td><td>24.7 MB</td><td>24.7 MB</td></tr>
      <tr><td>1,000,000</td><td>88.8 MB</td><td>44.8 MB</td><td>44.8 MB</td></tr>
    </tbody>
  </table>
  <p>
    <code>countBy</code> and the hand loop hold <strong>the same
    memory</strong> — within 0.1 MB at every scale — because both keep
    four counters and nothing else.
    <code>groupListsBy</code> materialises every one of the million
    entries into per-level <code>List</code>s just to take their lengths,
    and by N=1,000,000 that is 44 MB of garbage it has to allocate and the
    collector has to walk.
  </p>
  <p>
    That tax is also what makes it <em>erratic</em>. Across 25 samples at
    N=1,000,000, <code>groupListsBy</code> ranged 38.8–50.1 ms — an 11 ms
    spread — while FxDart ranged 19.1–20.3 ms and the hand loop
    27.9–30.4 ms. Its slow samples are collections the other two never
    trigger. So its gap is part pipeline and part garbage; the other two
    columns are just pipeline.
  </p>
  <p>
    The bar chart above still reads <em>tie</em> at N=10,000 even though
    FxDart is comfortably ahead there, because 365 µs against 191 µs is
    174 µs — real, but under the harness's 0.6 ms floor. Nobody perceives
    174 µs, so the badge refuses to claim a win.
  </p>
  <p>
    The fair summary, then: <strong><code>countBy</code> gives you a hand
    loop's memory profile and beats a hand loop's time by ~1.47×, with a
    named operator's readability.</strong> It is a rare case where the
    library version is simply the better choice on every axis — and the
    reason is not clever compilation, it is that the operator only has to be
    written carefully once.
  </p>
  <div class="callout">
    <strong>Method:</strong> measured on the machine named in the Benchmark
    section — 5 interleaved rounds × 5 measured iterations = 25 samples per
    implementation per scale, AOT-compiled, a fresh process per sample,
    medians reported. All three implementations return an identical
    checksum at every scale.
  </div>
