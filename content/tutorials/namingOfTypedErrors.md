---
slug: namingOfTypedErrors
title: Why "typed errors" (and not Monad) — FxDart 101
description: The naming rationale behind FxDart's typed errors: why the guide is not called Monad, why Arrow's vocabulary was chosen, and why raise was reserved.
heading: Why is it called "typed errors"?
section: 13
crumb: naming
---
  <p class="hero-sub">
    The feature behind <code>either</code> has famous names in other
    ecosystems — <a href="monad.html"><em>Monad</em></a>,
    <em>Railway-oriented programming</em>. This page explains why FxDart
    deliberately calls it none of those. (Never met a monad? Start with
    <a href="monad.html">Monad &amp; comprehension blocks</a>.)
  </p>

  <h2>Why not "Monad"?</h2>
  <p>
    Because it would misdescribe the feature. The whole point of the
    <code>Raise</code> design is that it is <em>not</em> monadic style — it
    exists to <strong>replace</strong> <code>flatMap</code>-chaining with
    straight-line code. You saw this on the
    <a href="typedErrors.html">typed errors page</a>: the
    <code>either((r) { ... })</code> block is the alternative to the nested
    <code>flatMap</code> pyramid, not a wrapper around it.
  </p>
  <p>
    Kotlin's Arrow — the design source for this feature — went through
    exactly this decision. Arrow 1.x had a <code>Monad</code> typeclass,
    higher-kinded-type emulation, and the Haskell vocabulary to go with it.
    Arrow 2.x <strong>deleted all of it</strong>, and even renamed the core
    operation <code>shift</code> → <code>raise</code> by community poll —
    choosing the word users understood over the word theory used. The lesson
    generalises: name for the audience you want, and FxDart's audience is
    ordinary Dart developers, not category theorists.
  </p>
  <p>
    There is also a cautionary tale in Dart itself: FP libraries whose public
    surface speaks Haskell (<code>Monad2</code>, <code>HKT</code>,
    <code>Do</code>-notation) intimidate exactly the developers who would
    benefit most from typed errors. A page called "Monad" would scare off its
    own readers — and describe the one thing this API isn't.
  </p>

  <h2>Why "typed errors"?</h2>
  <ul>
    <li><strong>It says what the feature does</strong> — errors carried in
      the type system instead of thrown past it — rather than what category
      theory calls the shape.</li>
    <li><strong>It is Arrow's own name.</strong> The corresponding chapter of
      the Arrow documentation is literally titled <em>Typed errors</em>, so
      Kotlin developers searching for the Dart equivalent land on the right
      words.</li>
    <li><strong>It follows the house rule.</strong> FxDart's naming
      philosophy (see <code>WHY_CURRIED.md</code>: "port the meaning, not the
      spelling") is: Dart names, not Haskell names — <code>map</code> not
      <code>fmap</code>, <code>flatMap</code> not <code>bind</code>-the-verb,
      <code>recover</code> not <code>handleErrorWith</code>.</li>
  </ul>

  <h2>Why not "raise"?</h2>
  <p>
    <code>raise</code> is the accurate "cool" name — it is what the DSL is
    actually called, and tutorial URLs here are function-named
    (<code>concurrent.html</code>, <code>fx.html</code>). It was reserved on
    purpose: if Section&nbsp;13 later gains per-function tutorial pages
    (<code>either.html</code>, <code>bind.html</code>, …), a
    <code>raise.html</code> overview would collide with the future
    <code>raise</code> function tutorial. <code>typedErrors.html</code> stays
    free as the section's overview page forever.
  </p>

  <h2>What about "Railway"?</h2>
  <p>
    <em>Railway-oriented programming</em> is a well-known metaphor for the
    same idea (a success track and a failure track). It is a fine mental
    model — and a poor page name: less searchable, not Arrow vocabulary, and
    a metaphor you must already know before it helps you.
  </p>

  <div class="callout">
    <strong>The principle in one line.</strong> A name is part of the API:
    it should tell a Dart developer what the thing does, in words they would
    search for — <em>typed errors</em> — not certify which abstraction it
    secretly is.
  </div>