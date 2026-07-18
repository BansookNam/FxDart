---
slug: unless
title: unless — FxDart 101
description: Tutorial de unless en FxDart: aplica una transformación solo cuando un predicado no se cumple, con un playground en vivo.
heading: <code>unless</code>
section: 10
crumb: unless
prev: when.html
prevLabel: when
next: throwError.html
nextLabel: throwError
---
  <p class="hero-sub">Aplica un callback cuando el predicado no se cumple; en caso contrario devuelve el valor sin tocar.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>unless</code> es <a href="when.html"><code>when</code></a> con la
    condición invertida: <code>unless(predicate, callback, value)</code> ejecuta
    <code>callback(value)</code> cuando <code>predicate(value)</code> es
    <strong>false</strong>, y devuelve <code>value</code> intacto cuando el
    predicado se cumple. Se lee muy bien para "pon un valor por defecto salvo que
    esta condición ya se cumpla": validación, relleno de datos que faltan,
    normalización de casos límite.
  </p>
  <p>
    Como en <code>when</code>, en Dart ambas ramas deben devolver el mismo tipo
    <code>T</code> (no hay tipos de retorno unión), y no existe forma
    encadenable — es una función data-first normal y corriente.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Rellenar datos que faltan</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>unless</code> para poner <code>'general'</code> en
    cualquier etiqueta que no se haya establecido.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="when.html"><code>when</code></a> — el hermano de unless con la condición inversa ·
    <a href="cases.html"><code>cases</code></a> — varios predicados en lugar de uno solo ·
    <a href="throwIf.html"><code>throwIf</code></a> — lanza en vez de sustituir el valor ·
    <a href="compact.html"><code>compact</code></a> — descarta los valores ausentes en lugar de rellenarlos
  </div>
