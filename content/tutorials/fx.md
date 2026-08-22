---
slug: fx
title: fx — FxDart 101
description: FxDart fx tutorial: the lazy chain model — fx, fxAsync, fxStream — and how nothing runs until a terminal operator pulls it.
heading: <code>fx</code>
section: 1
crumb: fx
next: pipe.html
nextLabel: pipe
---
  <p class="hero-sub">Wraps a sequence in a lazy, chainable pipeline — the typed heart of FxDart.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Everything in this course builds toward one idea: a <strong>chain</strong>.
    <code>fx(iterable)</code> wraps any <code>Iterable&lt;T&gt;</code> in an
    <code>Fx&lt;T&gt;</code> — an object with FxTS-style methods like
    <code>.map()</code>, <code>.filter()</code>, and <code>.take()</code>
    hung off it. Every one of those calls returns a <em>new</em>
    <code>Fx</code> wrapping a bit more lazy computation. None of it runs
    yet. <code>Fx</code> only starts doing work when you call a
    <strong>terminal operator</strong> — <code>toList()</code>,
    <code>each()</code>, <code>consume()</code>, <code>reduce()</code>, and
    friends — which pulls values through the whole chain, one at a time,
    from the terminal all the way back to the source.
  </p>
  <p>
    This laziness is why FxDart can safely chain over huge or infinite
    sequences (<code>range</code>, <code>cycle</code>, <code>repeat</code>):
    as long as something downstream — usually <code>take(n)</code> — decides
    how many values to actually pull, the upstream steps only ever run that
    many times.
  </p>
  <p>
    <code>fx</code> is the <em>sync</em> half of the chain. Its async
    counterparts are <code>fxAsync</code>, which wraps an
    <code>FxAsyncIterable</code> (the thing you get from <code>toAsync</code>,
    <code>fromStream</code>, or any <code>*Async</code> function), and
    <code>fxStream</code>, a shortcut that wraps a Dart <code>Stream</code>
    directly. Both return an <code>FxAsync&lt;T&gt;</code> chain whose
    methods accept functions that may return a <code>Future</code>, and
    whose terminal operators all return a <code>Future</code> you
    <code>await</code>. Switch from sync to async mid-chain with
    <code>.toAsync()</code>.
  </p>
  <p>
    Why does this exist at all, instead of just calling top-level functions
    like <code>map(f, iterable)</code>? Because Dart cannot type a variadic
    <code>pipe</code> the way FxTS's TypeScript can (see the next lesson) —
    <code>fx()</code> chaining is how FxDart gets fully typed, autocompletable
    pipelines instead.
  </p>

  <div class="callout">
    <strong>0.8.0 breaking change:</strong>
    <code>Fx&lt;T&gt;</code> is now an <strong>extension type</strong> that
    erases to the wrapped <code>Iterable&lt;T&gt;</code> at runtime. All
    documented APIs stay identical — chains work exactly as before. What breaks:
    <code>x is Fx&lt;T&gt;</code> checks (the type doesn't exist at runtime),
    and code that tried to extend or implement <code>Fx</code> directly (use the
    top-level functions instead). If you're using <code>fx()</code> the normal
    way, your code needs no changes.
  </div>

  <h2>Demo 1 · Nothing runs until the terminal op</h2>
  <p>Watch <code>calls</code> stay at 0 right after building the chain, then
    jump once <code>toList()</code> actually pulls the 5 values:</p>
  {{playground:0}}

  <h2>Demo 2 · fxAsync and fxStream</h2>
  <p>
    <code>fxAsync</code> wraps an <code>FxAsyncIterable</code> (here, from
    <code>toAsync</code>); <code>fxStream</code> wraps a <code>Stream</code>
    directly. Both give you the same chain methods, async-flavored:
  </p>
  {{playground:1}}

  <h2>The getter spelling</h2>
  <p>
    Every entry point also exists as a getter: <code>.fx</code> on an
    <code>Iterable</code>, an <code>FxAsyncIterable</code> or a
    <code>Stream</code>, and <code>.fxAsync</code> on an iterable of futures.
    They build exactly the same chain — the difference is only which end of
    the expression you read from:
  </p>
  <pre><code>// the function: you go back to the front to open the paren
fx(orders.where(isPaid)).groupBy((o) =&gt; o.customerId);

// the getter: left to right, the way .toList() reads
orders.where(isPaid).fx.groupBy((o) =&gt; o.customerId);</code></pre>
  <p>
    This is the Dart-idiomatic spelling, and it is free: <code>Fx</code> is an
    extension type, so the wrapper erases to the iterable itself, and a getter
    whose body is <code>this</code> is a static call the compiler deletes. Over
    a million-element <code>map</code> + <code>filter</code> + <code>sum</code>,
    the two forms measure 12.640 ms and 12.665 ms — the same number twice.
  </p>
  <p>
    <strong>These pages use <code>fx()</code> throughout.</strong> It is the
    name FxTS uses, and it is the one that takes an explicit type argument,
    which a getter cannot do postfix — <code>fx&lt;num&gt;(xs)</code> works
    where <code>xs.fx&lt;num&gt;</code> does not parse. Pick whichever reads
    better in your own code; they compile to the same thing.
  </p>
  <p>
    One asymmetry is worth knowing. Over an
    <code>Iterable&lt;Future&lt;T&gt;&gt;</code>, <code>.fx</code> gives you an
    <code>Fx&lt;Future&lt;T&gt;&gt;</code> — a chain over the futures rather
    than their values, which compiles and quietly does the wrong thing. That is
    what <code>.fxAsync</code> is for: it awaits them, so <code>T</code> is the
    resolved type and <code>concurrent(n)</code> has something to work with.
  </p>
  <pre><code>await responses.fxAsync.map(parse).concurrent(4).toList();</code></pre>

  <h2>Try it yourself</h2>
  <p>Exercise: build a chain that keeps scores of 60 or above, doubles them
    as bonus points, and takes only the first 2 results.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pipe.html"><code>pipe</code></a> — the dynamically-typed alternative ·
    <a href="toList.html"><code>toList</code></a> — the most common terminal op ·
    <a href="each.html"><code>each</code></a> — terminal op for side effects ·
    <a href="consume.html"><code>consume</code></a> — terminal op that discards results
  </div>
