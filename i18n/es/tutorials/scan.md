---
slug: scan
title: scan — FxDart 101
description: Tutorial de scan en FxDart: una acumulación progresiva y perezosa, con o sin valor inicial, con un playground en vivo.
heading: <code>scan</code>
section: 3
crumb: scan
prev: flat.html
prevLabel: flat
next: peek.html
nextLabel: peek
---
  <p class="hero-sub">Una acumulación progresiva y perezosa — como <code>reduce</code>, pero emite todos los valores intermedios en lugar de solo el último.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>scan</code> es <code>reduce</code>/<code>fold</code> con sus pasos
    intermedios a la vista: en lugar de colapsar un iterable en un único valor
    final, emite <em>todas</em> las acumulaciones parciales, incluido el propio
    valor inicial como primer valor. Ese detalle de que el primer valor es el valor inicial
    importa: <code>scan(f, 0, [1, 2, 3])</code> emite cuatro valores
    (<code>0</code> y luego tres sumas parciales), no tres.
  </p>
  <p>
    <code>scan1</code> es la variante sin valor inicial, portada de la sobrecarga
    <code>scan(f, iterable)</code> de FxTS (sin argumento de valor inicial). Usa el
    primer elemento del iterable como acumulador inicial y lo emite de
    inmediato, y luego sigue plegando el resto, reflejando la relación de
    <code>reduce</code> con <code>fold</code>. Sobre un iterable vacío,
    <code>scan1</code> no tiene primer elemento con el que arrancar, así que no
    emite nada en absoluto. Ten en cuenta que no hay método de cadena para
    <code>scan1</code> (solo <code>scan</code> está en
    <code>Fx</code>/<code>FxAsync</code>): llámalo en forma data-first,
    <code>scan1(f, iterable)</code>.
  </p>
  <p>
    Ambos son perezosos: no se ejecuta nada hasta que consumes la
    secuencia. En el lado
    asíncrono, <code>scanAsync</code>/<code>scan1Async</code> siguen plegando
    paso a paso y en orden (cada paso necesita el resultado anterior), así que
    <code>.concurrent(n)</code> no paraleliza el pliegue en sí; lo que sí hace
    es permitir que una etapa de descarga aguas arriba se ejecute con
    concurrencia, siempre que la propia función acumuladora sea barata. Mira la
    Demo 2.
  </p>

  <h2>Demo 1 · Fundamentos — scan y scan1</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia aguas arriba</h2>
  <p>
    El pliegue en sí sigue siendo secuencial, pero la descarga que lo alimenta
    no tiene por qué serlo:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>scan</code> para producir un total acumulado de
    pasos, con <code>0</code> como valor inicial.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="../tutorials/reduce.html"><code>reduce</code>/<code>fold</code></a> — colapsa a un único valor final ·
    <a href="flat.html"><code>flat</code></a> — aplana iterables anidados ·
    <a href="peek.html"><code>peek</code></a> — observa sin transformar ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación paralela
  </div>
