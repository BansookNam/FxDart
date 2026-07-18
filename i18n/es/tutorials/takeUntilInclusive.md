---
slug: takeUntilInclusive
title: takeUntilInclusive — FxDart 101
description: Tutorial de takeUntilInclusive en FxDart: toma valores hasta la primera coincidencia, incluyéndola, con playground en vivo.
heading: <code>takeUntilInclusive</code>
section: 5
crumb: takeUntilInclusive
prev: takeWhile.html
prevLabel: takeWhile
next: drop.html
nextLabel: drop
---
  <p class="hero-sub">Emite valores hasta que el predicado coincide — el elemento coincidente sí se incluye.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>takeUntilInclusive</code> es el pariente cercano de <code>takeWhile</code>,
    con una diferencia deliberada: emite el elemento que hizo verdadero el
    predicado y luego se detiene. <code>takeWhile</code> se detiene
    <em>antes</em> del elemento que falla; <code>takeUntilInclusive</code>
    se detiene <em>después</em> del que coincide. Recurre a él siempre que el
    elemento coincidente forme parte de la respuesta: «lee el log hasta el
    primer error, incluido», «recoge los pasos hasta el terminador, incluido».
  </p>
  <p>
    FxTS lo llamaba originalmente <code>takeUntil</code>; FxDart mantiene
    <code>takeUntil</code> (y <code>takeUntilAsync</code>) como alias
    <code>@Deprecated</code> por paridad con el original, pero el código nuevo
    debería llamar directamente a <code>takeUntilInclusive</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: toma las líneas del log hasta el primer
    <code>'ERROR'</code>, incluido.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="takeWhile.html"><code>takeWhile</code></a> — se detiene antes de la coincidencia y la excluye ·
    <a href="dropUntil.html"><code>dropUntil</code></a> — el equivalente en el lado de drop ·
    <a href="take.html"><code>take</code></a> — toma por cantidad
  </div>
