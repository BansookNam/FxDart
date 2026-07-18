---
slug: reject
title: reject — FxDart 101
description: Tutorial de reject en FxDart: exactamente lo contrario de filter, con un playground en vivo.
heading: <code>reject</code>
section: 4
crumb: reject
prev: filter.html
prevLabel: filter
next: compact.html
nextLabel: compact
---
  <p class="hero-sub">Se queda con todos los elementos para los que un predicado devuelve false — la imagen especular de filter.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>reject</code> está implementado como
    <code>filter((a) =&gt; !f(a), iterable)</code>: existe puramente por
    legibilidad. <code>list.reject(isInvalid)</code> se lee de forma más
    natural que <code>list.filter((a) =&gt; !isInvalid(a))</code>, sobre todo
    cuando el predicado ya tiene un nombre claro y en positivo. Elige entre
    <code>filter</code> y <code>reject</code> el que te evite escribir una
    negación en el punto de llamada.
  </p>
  <p>
    Todo el comportamiento de <code>filter</code> se traslada sin cambios: es
    perezoso, y la forma asíncrona hereda el camino concurrente dedicado de
    <code>filterAsync</code>, así que <code>.concurrent(n)</code> evalúa
    realmente <code>n</code> predicados en paralelo sin dejar de devolver los
    resultados en el orden original.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>reject</code> para descartar las líneas
    <code>'info: ok'</code> y quedarte solo con los errores.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="filter.html"><code>filter</code></a> — la función en la que reject delega ·
    <a href="compact.html"><code>compact</code></a> — descarta específicamente los nulos ·
    <a href="uniq.html"><code>uniq</code></a> — elimina duplicados ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación paralela
  </div>
