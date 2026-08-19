---
slug: takeUniqBy
title: takeUniqBy — FxDart 101
description: FxDart takeUniqBy tutorial: filter, dedupe and truncate in one strict call whose callback the compiler can inline — with a live playground.
heading: <code>takeUniqBy</code>
section: 4
crumb: takeUniqBy
prev: uniqAdjacent.html
prevLabel: uniqAdjacent
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">The first <em>count</em> elements whose key is new, as a list — a <code>null</code> key skips the element, so one callback both selects and keys.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>takeUniqBy(3, key, xs)</code> is
    <code><a href="filter.html">filter</a></code> +
    <code><a href="uniqBy.html">uniqBy</a></code> +
    <code><a href="take.html">take</a></code> written as a single strict call.
    It returns a <code>List</code>, it runs when you call it, and it stops the
    moment the count is met — the elements after that are never inspected.
    The one twist is the callback: it returns a key, and returning
    <code>null</code> means "skip this element". That is the
    <code>filter_map</code> shape, and it is what lets one function do the work
    of two.
  </p>
  <p>
    Write the chain by default. Three named steps read better than one
    callback doing two jobs, and the lazy chain short-circuits just as well.
    This operator exists for one reason, and it is worth knowing what it is.
  </p>

  <h2>Why it exists: the callback the compiler cannot see</h2>
  <p>
    A lazy stage keeps its callback in an <em>iterator field</em>. The AOT
    compiler cannot see through a field, so the closure never inlines — every
    element pays a real indirect call, and its body is never fused into the
    loop around it. Two stages, two calls per element. That is most of what
    separates an idiomatic FxDart chain from a hand-written loop.
  </p>
  <p>
    <code>takeUniqBy</code> takes its callback as a <em>parameter</em> of a
    body small enough to inline into the caller, so the compiler inlines the
    closure with it. Measured over 1,000,000 log lines, AOT:
  </p>
  <table>
    <thead><tr><th>Spelling</th><th>Time</th></tr></thead>
    <tbody>
      <tr><td><code>filter().uniqBy().take(3)</code></td><td>13.7 ms</td></tr>
      <tr><td><code>takeUniqBy(3, …)</code></td><td><strong>11.3 ms</strong></td></tr>
      <tr><td>a hand-written loop</td><td>10.2 ms</td></tr>
    </tbody>
  </table>
  <p>
    Both spellings, and both bars, are on
    <a href="../DartComparison/recent-errors.html">Recent error messages,
    deduped</a> — the one comparison page that publishes three bars instead of
    two, because the gap between two ways of writing the same pipeline is the
    point it makes.
  </p>
  <p>
    So: reach for this when the pipeline is hot and a profile says these
    callbacks are the cost. Not before. fxdart extension — no FxTS
    counterpart, and no async twin: the win is inlining, which the async
    machinery dwarfs.
  </p>

  <h2>Demo 1 · The three most recent distinct errors</h2>
  {{playground:0}}

  <h2>Demo 2 · null skips, count is a ceiling</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: the first three distinct users who landed on a page.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="uniqBy.html"><code>uniqBy</code></a> — the lazy dedup this folds in ·
    <a href="take.html"><code>take</code></a> — the lazy truncation this folds in ·
    <a href="uniqStrict.html"><code>uniqStrict</code></a> — the other strict member of the family ·
    <a href="performance.html">Performance</a> — where the callback floor comes from
  </div>
