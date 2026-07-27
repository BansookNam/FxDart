---
slug: valid-emails
title: First 5 valid emails, normalized — Dart vs FxDart
description: Trim, lowercase, validate, take five — map/where/take in plain Dart vs map + filter + take in FxDart. Plain Dart is every bit as clean here.
heading: First 5 valid emails, normalized
order: 19
tier: 2
functions: map, filter, take
alsoLink: fx, groupBy, scan, zip, concurrent
domain: users
verdict: native
async: false
---
  <h2>Requirement</h2>
  <p>
    Signup input is messy: stray whitespace, mixed case, and a couple of
    strings that are not emails at all. Normalize each entry (trim,
    lowercase), keep only plausible emails (contains <code>@</code> and a
    dot), and print the <strong>first five</strong>. The data is in the code
    below; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They don't, and that is the point. <code>map</code>, <code>where</code>,
    and <code>take</code> ship on every Dart <code>Iterable</code>, they are
    lazy, and the two versions are the same pipeline with <code>where</code>
    spelled <code>filter</code>. For a short normalize-validate-truncate
    chain like this, plain Dart is every bit as clear — reach for it. FxDart
    earns its keep when the pipeline needs vocabulary Dart lacks
    (<code>groupBy</code>, <code>scan</code>, <code>zip</code>,
    <code>concurrent</code>…) or when the rest of the file already chains
    with <code>fx</code>; adding a dependency for this snippet alone buys
    nothing.
  </p>
