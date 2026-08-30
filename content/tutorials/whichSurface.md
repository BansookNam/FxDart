---
slug: whichSurface
title: Which surface? — FxDart 101
description: FxDart decision page: which surface a job belongs on — fx() for data in hand, concurrent for bounded I/O, fxEvents for time, Either for failures the caller handles.
heading: Which surface?
section: 1
crumb: which surface
next: fx.html
nextLabel: fx
---
  <p class="hero-sub">Four surfaces, one import. Pick the surface the job is, then stay on it.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    FxDart is not four libraries in a trenchcoat. It is one package because
    a real program crosses these jobs, and the names stay the same when
    you do. The mistake is starting from a function list. Start from the
    job:
  </p>
  <table>
    <tr><th>The job is…</th><th>Start with</th><th>Not</th></tr>
    <tr>
      <td>Data already in hand; only part of it is needed</td>
      <td><code><a href="fx.html">fx(iterable)</a></code></td>
      <td>wrapping a one-line <code>map</code>/<code>where</code>/<code>take</code></td>
    </tr>
    <tr>
      <td>I/O over a known collection, at most <em>n</em> in flight, order kept</td>
      <td><code>.toAsync().map(f).concurrent(n)</code> or <code><a href="mapConcurrent.html">.mapConcurrent(n, f)</a></code></td>
      <td><code>Future.wait(xs.map(f))</code></td>
    </tr>
    <tr>
      <td>Values arrive when they arrive (keystrokes, ticks, sockets)</td>
      <td><code><a href="fxEvents.html">fxEvents(stream)</a></code></td>
      <td>a pull pipeline with <code>sleep</code></td>
    </tr>
    <tr>
      <td>The caller handles the failure</td>
      <td><code><a href="raise.html">either</a></code> / <code><a href="mapEither.html">mapEither</a></code> / <code><a href="attempt.html">attempt</a></code> on the surface you are already on</td>
      <td><code>throw</code> for domain errors; <code>null</code> with the reason lost</td>
    </tr>
  </table>
  <p>
    Pull names win collisions. <code>takeUntil</code> is the FxTS predicate;
    the events-layer analogue is <code><a href="stopOn.html">stopOn</a></code>.
    One word, one meaning. Cross at a named seam:
    <code>.toAsync()</code> lifts data into demand,
    <code>.pull()</code> lifts events into demand,
    <code>.toStream()</code> goes the other way.
  </p>

  <div class="callout">
    <strong>The 0.8.10 channel rule.</strong>
    <code>attempt</code> <strong>after</strong>
    <code><a href="retryOn.html">retryOn</a></code> /
    <code>retryOnError</code>, never before. Those operators watch the
    error channel; once a failure is a <code>Left</code> there is nothing
    left there to retry.
  </div>

  <p>
    Two jobs that cross surfaces are worked as tutorials of their own:
    <a href="job-search.html">debounced search</a> (time → latest query
    wins → typed parse) and
    <a href="job-fetch.html">bounded concurrent fetch</a> (a bound, order
    kept, every failure kept). The pull on-ramp still starts at
    <a href="fx.html"><code>fx</code></a>.
  </p>

  <h2>Demo · four jobs, four surfaces</h2>
  <p>
    The same import. Each block is the smallest program that belongs on
    that row of the table:
  </p>
  {{playground:0}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="fx.html"><code>fx</code></a> — the pull chain ·
    <a href="concurrent.html"><code>concurrent</code></a> — the I/O bound ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — the push chain ·
    <a href="typedErrors.html">typed errors</a> — failures as values ·
    <a href="job-search.html">debounced search</a> ·
    <a href="job-fetch.html">bounded concurrent fetch</a>
  </div>
