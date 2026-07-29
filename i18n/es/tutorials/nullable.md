---
slug: nullable
title: nullable — FxDart 101
description: Tutorial de nullable en FxDart: los constructores nullable y nullableAsync — desenvoltura en línea recta de valores nullables, la alternativa nullable-first a un tipo Option.
heading: <code>nullable</code>
section: 13
crumb: nullable
prev: raise.html
prevLabel: either &amp; Raise
next: nonEmptyList.html
nextLabel: NonEmptyList
---
  <p class="hero-sub">
    Ejecuta un bloque en un ámbito raise sin información: cualquier
    cortocircuito hace que todo el bloque se evalúe a <code>null</code>. La
    alternativa nullable-first a un tipo <code>Option</code>.
  </p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Cuando la única información de fallo que necesitas es la
    <em>ausencia</em>, un <code>Either</code> es excesivo — Dart ya tiene un
    canal dedicado a la ausencia: <code>T?</code>. <code>nullable</code> es el
    gemelo sin información del
    <a href="raise.html">constructor <code>either</code></a>
    (el port de <code>nullable&nbsp;{&nbsp;}</code> de Arrow): el
    <code>r.bind(value)</code> del ámbito desenvuelve un valor nullable y, si
    es <code>null</code>, todo el bloque devuelve <code>null</code>.
  </p>
  <p>
    Frente a encadenar <code>?.</code> y <code>??</code>, la ganancia es que
    <em>cualquier</em> paso puede abandonar — una búsqueda, un parseo, una
    condición vía <code>r.ensure(cond)</code> — sin anidamiento, y los valores
    intermedios siguen promovidos y no nulos. Por eso FxDart no incluye ningún
    tipo <code>Option</code>/<code>Maybe</code>: <code>T?</code> más este
    constructor lo cubren, sin ninguna envoltura.
  </p>

  <h2>Demo 1 · bind sobre tryParse</h2>
  {{playground:0}}

  <h2>Demo 2 · búsquedas profundas sin escaleras de ?.</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: <code>lastSeen['lee']</code> existe pero contiene
    <code>null</code>, y <code>'park'</code> falta por completo —
    <code>r.bind</code> trata ambos casos como ausencia. Arregla
    <code>describe</code> para que los dos impriman <code>null</code>.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="raise.html">constructor <code>either</code></a> — cuando el fallo necesita un motivo ·
    <a href="either.html"><code>Either</code></a> — <code>getOrNull()</code> hace de puente de vuelta a los nullables ·
    <a href="compact.html"><code>nonNulls</code></a> — elimina los nulls de un pipeline ·
    <a href="typedErrors.html">errores tipados — guía completa</a>
  </div>
