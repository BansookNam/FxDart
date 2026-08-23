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
    One habit is worth naming before the list, because it is common and it
    is a mistake. <code>Stream</code> carries a rich operator vocabulary,
    so it is tempting to reach for it by wrapping data you already hold —
    <code>Stream.fromIterable(orders)</code> — purely to get
    <code>map</code>, <code>where</code>, <code>distinct</code>,
    <code>expand</code> and a fluent chain, and then to
    <code>await</code> the answer back at the end. Nothing in that problem
    is asynchronous. The values are in memory, the question has an answer
    right now, and the <code>await</code> at the end is the tell: a
    synchronous question was converted into a delivery mechanism to
    borrow its syntax. What that buys is vocabulary; what it costs is a
    subscription, an event-loop turn, and a delivery step for every single
    element.
  </p>

  <p>
    The benchmarks below put a number on it. Across the
    <strong>25 examples whose source is already in memory</strong>, AOT-compiled
    and measured at <strong>N&nbsp;=&nbsp;1,000,000</strong>, the pull pipeline
    is faster in <strong>every one</strong> — a median of
    <strong>2.7×</strong>, rising to <strong>88×</strong> where a
    short-circuiting search stops early
    (<a href="first-over-budget-rx.html">#1</a>, 78.9&nbsp;ms vs
    0.9&nbsp;ms) and costing whole seconds on the heavier reports
    (<a href="stock-after-moves.html">#11</a>, 3.4&nbsp;s vs 175&nbsp;ms).
    Where the work is <em>genuinely</em> asynchronous, the same harness
    finds the two models level: across those 16 examples the median gap is
    <strong>1.05×</strong>, and most carry a tie badge. That contrast is
    the section in one line — streams are not slow, but putting
    synchronous data through one means paying for a delivery that never
    needed to happen.
  </p>

  <p>
    The converse deserves saying just as plainly: when a problem really is
    about <em>events over time</em> — user input, tickers, sockets — a
    stream is the right shape for it, and no amount of pipeline vocabulary
    replaces one. FxDart says so by absorbing the idea: its
    <strong>events layer</strong>
    (<code><a href="../tutorials/fxEvents.html">fxEvents</a></code>) puts
    Rx-style push operators — debounce, throttle, sample, combineLatest,
    switchMap, race, a <code>LiveValue</code> — on plain Dart streams, so
    Part&nbsp;4's time-shaped pairs meet as equals, operator for operator.
    RxDart still has a Subject class hierarchy and arity-suffixed
    <code>combineLatest2…9</code> overloads; fxdart covers the <em>jobs</em>
    on plain Dart streams without colliding with rxdart in the same file —
    windows, live <code>groupsBy</code>, <code>shareReplay</code>,
    selector-driven debounce, <code>combine</code>, the four
    <code>fromStream*</code> pull policies. What the pairs expose is the
    other half of the story — how often a problem that gets solved with a
    stream is really a <em>data pipeline</em> wearing a stream costume: a
    bounded fetch, a batch transform, a paginated crawl. For those, the
    pull version is shorter, ordered, typed, and needs no subscription
    lifecycle at all.
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
    wall-clock examples (#38–#46) are deliberately not benchmarked:
    debounce windows and sample ticks measure the clock, not the
    pipeline.
  </p>
