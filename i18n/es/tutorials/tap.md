---
slug: tap
title: tap — FxDart 101
description: Tutorial de tap en FxDart: ejecuta un efecto secundario sobre un valor y devuélvelo sin cambios, en forma data-first, con playground en vivo.
heading: <code>tap</code>
section: 10
crumb: tap
prev: always.html
prevLabel: always
next: apply.html
nextLabel: apply
---
  <p class="hero-sub">Llama a una función con un valor por su efecto secundario y luego devuelve el valor sin cambios.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>tap</code> es data-first: <code>tap(f, value)</code> ejecuta
    <code>f(value)</code> —normalmente un <code>print</code>, una llamada de
    log u otro efecto secundario— y luego te devuelve <code>value</code> tal
    cual. Existe para que puedas espiar un valor <em>sin romper la expresión
    de la que forma parte</em>: envuelve cualquier valor individual en
    <code>tap</code> y el código de alrededor no necesita cambiar en absoluto.
  </p>
  <p>
    <code>tap</code> opera sobre un valor cada vez. Su pariente
    <a href="peek.html"><code>peek</code></a> es la versión para pipelines:
    ejecuta un efecto secundario por cada elemento de un <code>Iterable</code>
    conforme se va tirando de él. Para tener un «logger» reutilizable y
    currificado, cierras tú mismo sobre <code>f</code>:
    <code>(v) => tap(f, v)</code>, como se ve abajo.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Registrar dentro de un pipe</h2>
  <p>
    Cerrar sobre <code>tap</code> te da un «logger» currificado y reutilizable
    que puedes soltar en una cadena <code>pipe</code> para inspeccionar valores
    intermedios sin alterar el flujo de datos:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>tap</code> para imprimir cada valor a su paso por
    el callback de <code>map</code>, antes de que se multiplique por 10.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="peek.html"><code>peek</code></a> — la versión de tap para pipelines ·
    <a href="pipe1.html"><code>pipe1</code></a> / <a href="pipe.html"><code>pipe</code></a> — compón un valor a través de funciones ·
    <a href="identity.html"><code>identity</code></a> — deja pasar sin ningún efecto secundario ·
    <a href="apply.html"><code>apply</code></a> — invoca una función con una lista dinámica de argumentos
  </div>
