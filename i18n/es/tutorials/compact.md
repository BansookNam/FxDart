---
slug: compact
title: nonNulls — FxDart 101
description: Tutorial de nonNulls en FxDart: descarta los null y estrecha el tipo del elemento, con un playground en vivo.
heading: <code>nonNulls</code>
section: 4
crumb: nonNulls
prev: reject.html
prevLabel: reject
next: uniq.html
nextLabel: uniq
---
  <p class="hero-sub">Filtra los null y, a la vez, estrecha el tipo del elemento de <code>T?</code> a <code>T</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>nonNulls</code> toma un <code>Iterable&lt;A?&gt;</code> y
    devuelve un <code>Iterable&lt;A&gt;</code> — cada <code>null</code>
    desaparece, y el verificador de tipos lo sabe: nada de lo que venga
    después necesita ya comprobar null. <code>nonNulls</code> es el nombre
    idiomático en Dart; fxdart también acepta la grafía <code>compact</code>
    de FxTS: son el mismo operador. El <code>compact</code> de FxTS descarta
    los seis valores falsy de JS (<code>undefined</code>, <code>null</code>,
    <code>0</code>, <code>''</code>, <code>NaN</code>, <code>false</code>);
    Dart no tiene un concepto único de «falsy», así que el port solo elimina
    <code>null</code> — un comportamiento deliberadamente más estrecho y
    fácil de razonar.
  </p>
  <p>
    Aparece constantemente después de <a href="pluck.html"><code>pluck</code></a>
    o de cualquier búsqueda que devuelva <code>T?</code>: <code>nonNulls(pluck(key, records))</code>
    te da una lista limpia y no nullable en un solo paso.
  </p>
  <p>
    En la cadena síncrona, <code>.nonNulls</code> es un <strong>getter
    heredado de <code>Iterable</code></strong> — escríbelo sin paréntesis
    (<code>fx(xs).nonNulls</code>) y, como devuelve un
    <code>Iterable&lt;A&gt;</code> normal, envuélvelo en <code>fx(...)</code>
    para seguir encadenando. No hay getter asíncrono, así que en un pipeline
    asíncrono usa la función de nivel superior <code>nonNullsAsync(...)</code>
    (o su alias de FxTS <code>compactAsync</code>) y envuélvela con
    <code>fxAsync(...)</code>.
  </p>

  <h2>Demo 1 · Fundamentos &amp; estrechamiento de tipos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>nonNulls</code> para descartar los null de
    <code>answers</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pluck.html"><code>pluck</code></a> — una fuente habitual de valores nullable ·
    <a href="reject.html"><code>reject</code></a> — descarta según un predicado cualquiera ·
    <a href="../tutorials/compactObject.html"><code>compactObject</code></a> — el equivalente para Map ·
    <a href="uniq.html"><code>uniq</code></a> — elimina duplicados
  </div>
