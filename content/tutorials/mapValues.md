---
slug: mapValues
title: mapValues, mapKeys &amp; mapEntries — FxDart 101
description: FxDart mapValues tutorial: transform every value, key, or whole entry of a Map, with a live playground.
heading: <code>mapValues</code> &amp; friends
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
    <a href="pick.html"><code>pick</code></a>,
    <a href="omit.html"><code>omit</code></a>,
    <a href="pickBy.html"><code>pickBy</code></a>,
    <a href="omitBy.html"><code>omitBy</code></a> — or reads one part of it.
    These three <em>transform</em> it. <code>mapValues</code> runs every value
    through a callback and leaves the keys alone, <code>mapKeys</code> does
    the reverse, and <code>mapEntries</code> takes the whole
    <code>(key, value)</code> record and gives back a new one.
  </p>
  <p>
    That record is the same shape <code>pickBy</code>, <code>omitBy</code> and
    <a href="fromEntries.html"><code>fromEntries</code></a> already use, so
    the four compose without any adapting: filter with one, transform with the
    other. <code>mapEntries</code> generalises the other two — swapping
    <code>e.$1</code> and <code>e.$2</code> inverts a map in one call.
  </p>
  <p>
    <code>mapValues</code> can never lose an entry, because the keys are
    untouched. <code>mapKeys</code> and <code>mapEntries</code> can: if the
    callback maps two keys onto the same result, the <strong>last</strong> one
    in iteration order wins, exactly as a repeated key in a map literal would.
    Insertion order otherwise survives, following the first appearance of each
    new key.
  </p>
  <p>
    There is deliberately no <code>filter</code> or <code>filterWithKey</code>
    here. <code>pickBy</code> and <code>omitBy</code> already take the whole
    record, so ignoring one half is how you filter by the other — see the
    second demo.
  </p>
  <p>
    Compare <a href="evolve.html"><code>evolve</code></a>, next door: it
    transforms the values of <em>named</em> keys and passes the rest through.
    <code>mapValues</code> is the case where every value gets the same
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
    <a href="evolve.html"><code>evolve</code></a> — transform the values of named keys only ·
    <a href="pickBy.html"><code>pickBy</code></a> / <a href="omitBy.html"><code>omitBy</code></a> — the key-aware filters, same record shape ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — build a map from records ·
    <a href="compactObject.html"><code>compactObject</code></a> — drop the null values
  </div>
