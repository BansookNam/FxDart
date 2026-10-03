---
slug: mapValues
title: mapValues, mapKeys &amp; mapEntries — FxDart 101
description: FxDart mapValues tutorial: transform every value, key, or whole entry of a Map, with a live playground.
heading: <code>fxMapValues</code> &amp; friends
section: 9
crumb: mapValues
prev: props.html
prevLabel: props
next: evolve.html
nextLabel: evolve
---
  <p class="hero-sub">Transforms every value, every key, or the whole <code>(key, value)</code> entry of a map.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The rest of section 9 <em>selects</em> from a map —
    <a href="pick.html"><code>fxPick</code></a>,
    <a href="omit.html"><code>fxOmit</code></a>,
    <a href="pickBy.html"><code>fxPickBy</code></a>,
    <a href="omitBy.html"><code>fxOmitBy</code></a> — or reads one part of it.
    These three <em>transform</em> it. <code>fxMapValues</code> runs every value
    through a callback and leaves the keys alone, <code>fxMapKeys</code> does
    the reverse, and <code>fxMapEntries</code> takes the whole
    <code>(key, value)</code> record and gives back a new one.
  </p>
  <p>
    That record is the same shape <code>fxPickBy</code>, <code>fxOmitBy</code> and
    <a href="fromEntries.html"><code>fxFromEntries</code></a> already use, so
    the four compose without any adapting: filter with one, transform with the
    other. <code>fxMapEntries</code> generalises the other two — swapping
    <code>e.$1</code> and <code>e.$2</code> inverts a map in one call.
  </p>
  <p>
    <code>fxMapValues</code> can never lose an entry, because the keys are
    untouched. <code>fxMapKeys</code> and <code>fxMapEntries</code> can: if the
    callback maps two keys onto the same result, the <strong>last</strong> one
    in iteration order wins, exactly as a repeated key in a map literal would.
    Insertion order otherwise survives, following the first appearance of each
    new key.
  </p>
  <p>
    There is deliberately no <code>filter</code> or <code>filterWithKey</code>
    here. <code>fxPickBy</code> and <code>fxOmitBy</code> already take the whole
    record, so ignoring one half is how you filter by the other — see the
    second demo.
  </p>
  <p>
    Compare <a href="evolve.html"><code>fxEvolve</code></a>, next door: it
    transforms the values of <em>named</em> keys and passes the rest through.
    <code>fxMapValues</code> is the case where every value gets the same
    treatment.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Collisions, and filtering alongside</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: turn every score into a letter grade, keeping the names.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="evolve.html"><code>fxEvolve</code></a> — transform the values of named keys only ·
    <a href="pickBy.html"><code>fxPickBy</code></a> / <a href="omitBy.html"><code>fxOmitBy</code></a> — the key-aware filters, same record shape ·
    <a href="fromEntries.html"><code>fxFromEntries</code></a> — build a map from records ·
    <a href="compactObject.html"><code>fxCompactObject</code></a> — drop the null values
  </div>
