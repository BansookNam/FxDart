---
slug: throwIf
title: throwIf — FxDart 101
description: Tutorial de throwIf en FxDart: lanza de forma condicional y, si no, deja pasar el valor, con playground en vivo.
heading: <code>throwIf</code>
section: 10
crumb: throwIf
prev: throwError.html
prevLabel: throwError
next: cases.html
nextLabel: cases
---
  <p class="hero-sub">Lanza cuando se cumple un predicado; en caso contrario devuelve el valor sin cambios.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>throwIf(predicate, toError, value)</code> es una cláusula de guarda
    que puedes soltar en mitad de una expresión: si
    <code>predicate(value)</code> es true, lanza
    <code>toError(value)</code>; si no, te devuelve <code>value</code> sin
    cambios. Eso lo hace cómodo dentro de un callback de <code>map</code>,
    cuando quieres validar cada elemento a su paso por el pipeline y fallar
    ruidosamente en cuanto uno no sea válido.
  </p>
  <p>
    Es básicamente <a href="when.html"><code>when</code></a> con una rama
    «then» que siempre lanza en lugar de devolver un valor — así que envuelve
    cualquier punto de llamada en <code>try</code>/<code>catch</code> para
    observar el fallo o recuperarte de él.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Validar un pipeline</h2>
  <p>
    Cada edad se valida conforme se mapea; la primera infracción aborta la
    llamada entera a <code>toList()</code>:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>throwIf</code> para protegerte del stock a cero
    mientras sumas este inventario.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="throwError.html"><code>throwError</code></a> — una función que lanza por sí sola, sin condición ·
    <a href="when.html"><code>when</code></a> — sustituye un valor en vez de lanzar ·
    <a href="cases.html"><code>cases</code></a> — despacha entre varios predicados ·
    <a href="add.html"><code>add</code></a> — usado arriba como reductor
  </div>
