---
slug: foldBy
title: foldBy — FxDart 101
description: FxDart foldBy tutorial: fold the values under each key in one pass, without materializing the groups, with a live playground.
heading: <code>foldBy</code>
section: 7
crumb: foldBy
prev: countBy.html
prevLabel: countBy
next: countWhere.html
nextLabel: countWhere
---
  <p class="hero-sub">Folds the values under each key in one pass — the aggregate without the groups.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>foldBy</code> is <code><a href="fold.html">fold</a></code> run once
    per key instead of once over the whole source. Each element picks its key,
    and its value is folded into that key's accumulator — so the result is a
    <code>Map&lt;K, Acc&gt;</code> of answers, not of elements.
  </p>
  <p>
    The reason it exists is what it <em>doesn't</em> do.
    <code><a href="groupBy.html">groupBy</a></code> followed by a fold per
    group has to build a <code>List</code> for every key first: allocation
    proportional to the <strong>input</strong>, for an answer proportional to
    the <strong>number of keys</strong>. When all you want is the total per
    category, those lists are built and thrown away. <code>foldBy</code>
    accumulates straight into the result map, which is exactly what the
    hand-written loop does:
  </p>
  <pre><code>// what you would write by hand
for (final t in txns) {
  totals[t.category] = (totals[t.category] ?? 0) + t.amount;
}

// the same thing, named
foldBy((Tx t) =&gt; t.category, 0.0, (sum, t) =&gt; sum + t.amount, txns);</code></pre>
  <p>
    On a million transactions across five categories that difference measured
    <strong>3.2× down to 1.3×</strong> of the hand-written loop. Several of the
    <a href="../DartComparison/index.html">Dart vs FxDart</a> examples moved
    onto it for exactly this reason.
  </p>
  <p>
    Keys come out in <strong>first-seen order</strong>, like
    <code>groupBy</code>. Not an FxTS port — the shape is Kotlin's
    <code>groupingBy().fold()</code>.
  </p>

  <div class="callout">
    <strong>The seed is a value, not a factory.</strong> Just as in
    <code>fold</code>, <code>seed</code> is one value used as the starting
    point for <em>every</em> key. That is fine for numbers and strings, which
    you fold into new values. A <strong>mutable</strong> seed — a list, a set,
    a map — would be shared by every key and mutated by all of them. If you
    need to accumulate into a mutable structure per group, use
    <code><a href="groupBy.html">groupBy</a></code>.
  </div>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>
    Exercise: the demo counts <strong>words</strong> per first letter. Change
    it to total the <strong>letters</strong> under each first letter, so
    <code>fig</code> and <code>fx</code> give <code>{f: 5}</code>.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>When not to use it:</strong> an accumulator that needs two running
    values — a mean needs a sum <em>and</em> a count — has to carry them in a
    record, and a record is allocated per element. That costs more than the
    grouping it avoids; reach for <code>groupBy</code> there.
  </div>

  <div class="callout">
    <strong>Related:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — keep the elements instead of folding them ·
    <a href="countBy.html"><code>countBy</code></a> — <code>foldBy</code> with a counter, pre-named ·
    <a href="fold.html"><code>fold</code></a> — the same fold over one accumulator ·
    <a href="groupedBy.html"><code>groupedBy</code></a> — grouping that stays in the chain
  </div>
