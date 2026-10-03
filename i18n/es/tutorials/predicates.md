---
slug: predicates
title: predicates — FxDart 101
description: Predicados de tipo de FxDart: isNull, isBool, isNum, isString, isDateTime, isList, isMap y compañía, listos para usar con filter.
heading: <code>predicates</code>
section: 8
crumb: predicates
prev: some.html
prevLabel: some
next: fromEntries.html
nextLabel: fromEntries
---
  <p class="hero-sub">Una pequeña familia de comprobaciones de tipo y de valor, disponibles como funciones que se pasan tal cual a <code>filter</code>, <code>takeWhile</code> y compañía.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    En Dart del día a día escribirías simplemente <code>a is String</code>: es
    lo idiomático y nada de aquí lo sustituye. Estas funciones existen por un
    motivo muy concreto: el operador <code>is</code> de Dart no se puede pasar
    como valor de función, pero <code>filter</code>, <code>takeWhile</code>,
    <code>find</code> y compañía esperan un <code>bool Function(A)</code>.
    <code>fxFilter(isString, mixedList)</code> se lee mejor que
    <code>fxFilter((a) => a is String, mixedList)</code>, y de eso va toda esta
    página.
  </p>
  <p>
    <code>fxIsNil</code> es un port directo de la comprobación «es
    <code>null</code> o <code>undefined</code>» de FxTS; como Dart colapsa
    ambos en <code>null</code>, es idéntica byte a byte a <code>fxIsNull</code>.
    Existen tres nombres más solo por paridad con FxTS, marcados como
    <code>@Deprecated</code>: <code>fxIsUndefined</code> (en Dart no hay
    <code>undefined</code>, así que es <code>fxIsNull</code> a secas),
    <code>fxIsArray</code> (el <code>Array</code> de JS → <code>List</code> en
    Dart, así que es <code>fxIsList</code>) e <code>fxIsObject</code> (el objeto
    plano de JS → <code>Map</code> en Dart, así que es <code>fxIsMap</code>). En
    código nuevo usa el nombre no obsoleto; los alias están ahí para que las
    llamadas portadas sigan compilando.
  </p>

  <h2>Demo 1 · Predicados listos para filtrar</h2>
  {{playground:0}}

  <h2>Demo 2 · <code>fxIsNil</code> y los alias obsoletos</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>isNotNull</code> para filtrar el <code>null</code> de <code>row</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="filter.html"><code>filter</code></a> — el sitio habitual donde se enchufan ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — una comprobación de valor, no de tipo ·
    <a href="compact.html"><code>fxCompact</code></a> — descarta los nulls de un iterable ·
    <a href="matches.html"><code>fxMatches</code></a> — un predicado de forma, no de tipo
  </div>
