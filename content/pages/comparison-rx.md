---
slug: comparison-rx
title: RxDart vs FxDart — two models, side by side
description: 50 real tasks solved twice — RxDart streams vs FxDart pull pipelines — each pair runnable in the browser, with an honest verdict on which model fits.
---
  <h1>RxDart vs FxDart</h1>
  <p class="hero-sub">
    The same real task, solved twice: RxDart on the left, FxDart on the
    right. Both versions run in your browser and print exactly the same
    output — compare the two models and decide which model your problem
    actually is.
  </p>

  <p>
    These two libraries are not rivals so much as <strong>complements</strong>.
    RxDart extends Dart's <code>Stream</code> — a <em>push</em> model where
    the producer decides when values arrive, which makes wall-clock
    operators (<code>debounceTime</code>, <code>combineLatest</code>,
    <code>switchMap</code>) and multicast (<code>BehaviorSubject</code>)
    natural. FxDart works on iterables — a <em>pull</em> model where the
    consumer decides when to ask, which makes laziness, typed error
    handling, and ordered bounded concurrency
    (<code><a href="../tutorials/concurrent.html">.concurrent(n)</a></code>)
    natural, and makes backpressure a non-problem: not pulling
    <em>is</em> the backpressure. The two meet at the bridges —
    <code><a href="../tutorials/streams.html">fromStream / toStream</a></code> —
    and several examples below use both libraries together on purpose.
  </p>

  <p>
    A word of honesty before the list: when a problem is genuinely about
    <em>events over time</em> — user input, tickers, sockets — a stream is
    the right shape for it. FxDart says so by absorbing the idea: since
    0.7.3 its <strong>events layer</strong>
    (<code><a href="../tutorials/fxEvents.html">fxEvents</a></code>) puts
    Rx-style push operators — debounce, throttle, sample, combineLatest,
    switchMap, race, a <code>LiveValue</code> — on plain Dart streams, so
    Part&nbsp;4's time-shaped pairs now meet as equals, operator for
    operator. RxDart's catalog remains far larger; what the pairs expose
    is the other half of the story — how often a problem that gets solved
    with a stream is really a <em>data pipeline</em> wearing a stream
    costume: a bounded fetch, a batch transform, a paginated crawl. For
    those, the pull version is shorter, ordered, typed, and needs no
    subscription lifecycle at all.
  </p>

  <p>
    <span class="badge verdict-fxdart">FxDart wins</span> — the pull model fits this problem better ·
    <span class="badge verdict-tie">Toss-up</span> — both models express it cleanly ·
    <span class="badge badge-async">async</span> — uses async pipelines
  </p>

  <p class="dim">
    Pages whose task is throughput-shaped also carry a
    <strong>Benchmark</strong> section — both implementations AOT-compiled
    and measured at N=100 and a large-N headline (1M for synchronous
    tasks; 10,000 where every element crosses the event loop). The
    wall-clock examples (#39–#47) are deliberately not benchmarked:
    debounce windows and sample ticks measure the clock, not the
    pipeline.
  </p>
