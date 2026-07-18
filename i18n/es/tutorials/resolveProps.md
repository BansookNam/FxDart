---
slug: resolveProps
title: resolveProps — FxDart 101
description: Tutorial de resolveProps en FxDart: espera todos los valores de un Map a la vez, el análogo con forma de mapa de Future.wait.
heading: <code>resolveProps</code>
section: 9
crumb: resolveProps
prev: compactObject.html
prevLabel: compactObject
next: isMatch.html
nextLabel: isMatch
---
  <p class="hero-sub">Espera todos los valores de un <code>Map</code> y devuelve el <code>Map</code> ya resuelto — el análogo con forma de mapa de <code>Future.wait</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>resolveProps</code> resuelve un tipo de problema concreto y muy
    habitual: tienes un <code>Map</code> cuyos valores son una mezcla de
    valores normales y <code>Future</code>s —por ejemplo, varias llamadas a API
    independientes indexadas por nombre de campo— y quieres recibir un único
    <code>Future</code> con el mapa entero ya resuelto.
  </p>
  <p>
    Internamente recorre las entradas y hace <code>await</code> sobre cada
    valor uno tras otro, lo que parece que debería ser <em>secuencial</em>. En la
    práctica, normalmente no es más lento que lanzarlos todos "a la vez": en
    Dart, un <code>Future</code> empieza a ejecutarse en el momento en que se
    <em>crea</em>, no cuando se espera. Así que si construyes el mapa con
    <code>delay(...)</code> o con peticiones que ya están en vuelo como valores
    —la forma habitual de llamar a esta función—, todas ellas ya se están
    ejecutando cuando <code>resolveProps</code> recibe el mapa; su bucle
    secuencial de <code>await</code> se limita a leer resultados que en su
    mayoría ya están listos, no a decidir cuándo empieza el trabajo. La demo de
    abajo lo demuestra con un cronómetro.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Los futures ya se solapan</h2>
  <p>Tres esperas de 100 ms, pero el conjunto termina muy por debajo de 300 ms, porque todas arrancaron a la vez:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>resolveProps</code> para esperar todos los valores de <code>requests</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="evolve.html"><code>evolve</code></a> — el primo síncrono, que transforma en lugar de esperar ·
    <a href="concurrent.html"><code>concurrent</code></a> — la versión con forma de iterable de "ejecutar cosas a la vez" ·
    <a href="delay.html"><code>delay &amp; sleep</code></a> — se usan para construir los futures de la demo ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — construye un Map desde cero
  </div>
