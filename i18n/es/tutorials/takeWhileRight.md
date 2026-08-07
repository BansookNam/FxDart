---
slug: takeWhileRight
title: takeWhileRight — FxDart 101
description: Tutorial de takeWhileRight en FxDart: conserva la racha final más larga que cumple un predicado, en el orden de la fuente, con playground en vivo.
heading: <code>takeWhileRight</code>
section: 5
crumb: takeWhileRight
prev: takeWhile.html
prevLabel: takeWhile
next: takeUntilInclusive.html
nextLabel: takeUntilInclusive
---
  <p class="hero-sub">Conserva la racha más larga del <em>final</em> de una fuente en la que se cumple un predicado, en el orden de la fuente.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <a href="takeRight.html"><code>takeRight</code></a> toma los últimos
    <em>n</em> elementos; <code>takeWhileRight</code> toma los últimos que
    <em>coinciden</em>, sean los que sean. Es a
    <code>takeRight</code> lo que <a href="takeWhile.html"><code>takeWhile</code></a>
    es a <a href="take.html"><code>take</code></a>: un predicado donde el
    otro quería una cantidad.
  </p>
  <p>
    Solo cuenta la racha que llega hasta el final. Si el último elemento ya
    falla, el resultado está vacío por larga que fuera la racha que había
    justo antes. Eso es lo que lo convierte en un operador de sufijo y no en
    una búsqueda de «la racha más larga en cualquier parte».
  </p>
  <p>
    El resultado vuelve en el <strong>orden de la fuente</strong>, no invertido,
    así que encadena con todo lo demás de la biblioteca y encaja con
    <a href="dropWhileRight.html"><code>dropWhileRight</code></a>: entre los
    dos parten una fuente sin perder ni repetir nada.
  </p>
  <p>
    No puede emitirse nada antes de que la fuente termine: hasta que no llega
    el último elemento, no se sabe de ningún elemento que pertenezca al
    sufijo. Sobre una <code>List</code> la racha final se busca caminando
    hacia atrás desde el final, así que el predicado solo ve esa racha; sobre
    cualquier otra fuente se prueba cada elemento en orden y la racha actual
    se almacena en memoria. Mantén el predicado puro y la diferencia no te
    alcanzará.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, y el reparto</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: conserva solo la racha final de lecturas iguales o superiores a 30.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="dropWhileRight.html"><code>dropWhileRight</code></a> — el complemento: descarta esa misma racha ·
    <a href="takeRight.html"><code>takeRight</code></a> — un tramo final por cantidad ·
    <a href="takeWhile.html"><code>takeWhile</code></a> — la misma idea desde el principio ·
    <a href="filter.html"><code>filter</code></a> — coincidencias en cualquier parte, no solo al final
  </div>
