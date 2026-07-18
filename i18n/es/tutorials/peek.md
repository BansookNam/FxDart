---
slug: peek
title: peek — FxDart 101
description: Tutorial de peek en FxDart: observa los elementos que pasan por un pipeline sin transformarlos, con playground en vivo.
heading: <code>peek</code>
section: 3
crumb: peek
prev: scan.html
prevLabel: scan
next: pluck.html
nextLabel: pluck
---
  <p class="hero-sub">Ejecuta una función por cada elemento sin cambiar nada: el equivalente en un pipeline a un breakpoint del depurador.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>peek</code> es el primo estricto de <code>mapEffect</code>:
    mientras que <code>mapEffect</code> aún puede cambiar el valor (es
    <code>map</code> con otro nombre), el callback de <code>peek</code>
    devuelve <code>void</code> — solo tiene permiso para mirar. El elemento
    que entra sale intacto. Recurre a él para colar un <code>print</code>,
    una métrica o una línea de log en mitad de un pipeline mientras depuras,
    sin arriesgarte a que una errata mute los datos en silencio.
  </p>
  <p>
    Es tan perezoso como todo lo demás por aquí: el callback se dispara
    exactamente una vez por cada elemento que el pipeline llega a producir,
    en orden, y ni un momento antes.
  </p>
  <p>
    <code>peekAsync</code> está construido directamente sobre
    <code>mapAsync</code> (espera a <code>f</code> y luego vuelve a emitir el
    valor original), así que comparte exactamente el comportamiento de
    concurrencia de <code>map</code>: <code>.concurrent(n)</code> ejecuta de
    verdad <code>n</code> callbacks en paralelo, a diferencia de
    <code>flatMap</code> o <code>scan</code>, cuyas máquinas de estado
    internas tienen que seguir siendo secuenciales.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Los mismos valores entran y salen: <code>peek</code> solo
    observa:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia real</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>peek</code> para imprimir
    <code>'checking price: $p'</code> por cada precio sin cambiar los
    valores, y luego súmalos con <code>fold</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="mapEffect.html"><code>mapEffect</code></a> — como peek, pero puede transformar ·
    <a href="map.html"><code>map</code></a> — transformar cada elemento ·
    <a href="pluck.html"><code>pluck</code></a> — extraer un campo de cada map ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
