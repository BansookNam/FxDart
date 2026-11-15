---
slug: mapCatching
title: mapCatching — FxDart 101
description: Tutorial de mapCatching en FxDart: recupera el error de cada elemento en su sitio para que una fila mala nunca termine el pipeline, síncrono y asíncrono, sin tocar los errores tipados.
heading: <code>fxMapCatching</code>
section: 11
crumb: mapCatching
prev: retry.html
prevLabel: retry
next: timeout.html
nextLabel: timeout
---
  <p class="hero-sub">Un <code>map</code> en el que el fallo de cada elemento se sustituye por un valor — una fila mala nunca termina la iteración.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un <code><a href="map.html">map</a></code> cuyo callback lanza una
    excepción termina todo el pipeline en ese elemento: una fila mal formada
    entre diez mil y obtienes una excepción, no nueve mil novecientos noventa
    y nueve resultados. <code>mapCatching(f, onError)</code> ejecuta
    <code>f</code> sobre cada elemento y, cuando lanza, entrega el error y su
    stack trace a <code>onError</code> y emite lo que este devuelve <em>en el
    lugar del elemento fallido</em>. El siguiente elemento se mapea como si
    nada hubiera pasado. Sigue siendo perezoso, y en <code>Fx</code> se queda
    en la cadena síncrona — no hay nada que esperar.
  </p>
  <p>
    Está al lado de <code><a href="retry.html">mapRetry</a></code>, y los dos
    son las dos respuestas a un elemento que falla: <code>mapRetry</code> lo
    ejecuta <em>otra vez</em>; <code>mapCatching</code> se rinde y lo
    sustituye. La forma asíncrona, <code>fxMapCatchingAsync</code> /
    <code>fxAsync(…).mapCatching</code>, permite que tanto <code>f</code>
    como <code>onError</code> esperen con await, y está construida sobre el
    <code>fxMapAsync</code> seguro en paralelo, así que bajo
    <code><a href="concurrent.html">concurrent(n)</a></code> cada elemento en
    vuelo se recupera por su cuenta y el orden se conserva. RxDart lo escribe
    como <code>onErrorReturnWith</code>; en un
    <a href="fxEvents.html">stream push</a> de fxdart los vecinos son
    <a href="onErrorResume.html"><code>onErrorReturn</code></a>, que
    sustituye cada error por un único valor fijo, y
    <a href="attempt.html"><code>attempt</code></a>, que conserva el error
    como un <code>Left</code> en lugar de reemplazarlo.
  </p>
  <p>
    Hay una cosa que <strong>nunca</strong> se recupera: la señal de raise de
    la propia biblioteca. Un <code>r.raise(…)</code> — desde un
    <code>bind</code>, un <code>ensure</code> o un constructor anidado — que
    atraviesa <code>f</code> se relanza, así que sigue cortocircuitando el
    bloque <a href="raise.html"><code>fxEither</code></a> /
    <a href="nullable.html"><code>fxNullable</code></a> que lo envuelve.
    Recuperarla convertiría un error tipado en uno perdido. Como con cualquier
    pipeline perezoso dentro de un bloque raise, materialízalo
    (<code>toList()</code>) dentro del bloque. Extensión de fxdart (no forma
    parte de FxTS).
  </p>

  <h2>Demo 1 · Una fila mala, recuperada en su sitio</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono bajo concurrent, y raise que pasa de largo</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: sustituye el bucle <code>try</code>/<code>catch</code> por un solo operador.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="retry.html"><code>retry</code></a> — ejecuta el elemento otra vez en lugar de sustituirlo ·
    <a href="onErrorResume.html"><code>onErrorReturn</code></a> — la misma idea en un stream push ·
    <a href="eitherPipelines.html">errores tipados</a> — cuando el fallo debe seguir siendo un valor que puedas inspeccionar
  </div>
