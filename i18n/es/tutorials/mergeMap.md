---
slug: mergeMap
title: mergeMap — FxDart 101
description: Tutorial de mergeMap en FxDart: mapea eventos a streams internos y ejecútalos todos a la vez, en orden con concatMap, o gana el primero con exhaustMap — con playground en vivo.
heading: <code>mergeMap</code>, <code>concatMap</code> &amp; <code>exhaustMap</code>
section: 14
crumb: mergeMap
prev: switchMap.html
prevLabel: switchMap
next: race.html
nextLabel: race
---
  <p class="hero-sub">Tres respuestas más a «llegó un evento mientras el anterior sigue en marcha»: ejecutarlos todos, ejecutarlos en orden, o ignorar el nuevo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Mapear un evento a un <em>stream interno</em> —una petición, una subida,
    una consulta— plantea una pregunta que un pipeline pull nunca tiene que
    responder: ¿qué pasa cuando el siguiente evento llega antes de que el
    último stream interno haya terminado? Hay exactamente cuatro políticas
    sensatas, y elegir la equivocada es donde vive la mayoría de los bugs
    reactivos. <code><a href="switchMap.html">switchMap</a></code> es la
    respuesta de «gana el último»; estas tres son las otras tres.
  </p>
  <p>
    <code>mergeMap(f)</code> ejecuta todos los streams internos
    <strong>a la vez</strong> e intercala su salida por orden de llegada. Úsalo
    cuando todos los resultados importan y ninguno reemplaza a otro: subir
    tres ficheros, abanicarse hacia tres servicios. Con
    <code>concurrent: n</code> se ejecutan como mucho <em>n</em> a la vez y el
    resto espera en cola, que es como evitas que un abanico abra doscientos
    sockets.
  </p>
  <p>
    <code>concatMap(f)</code> los ejecuta <strong>estrictamente en orden</strong>,
    cada uno hasta terminar antes de que empiece el siguiente. Nada se solapa
    y nada se descarta, así que un stream interno lento atasca la cadena
    entera; eso es justo lo que quieres cuando el orden es la condición de
    corrección, como en «aplica estas ediciones en secuencia».
  </p>
  <p>
    <code>exhaustMap(f)</code> se queda con el <strong>primero</strong> e
    ignora el resto: mientras un stream interno está en marcha, los eventos
    entrantes se descartan sin más — ni encolados ni cancelados. Esta es la
    protección contra el doble envío. Un segundo toque en un botón cuya
    petición sigue en vuelo no hace absolutamente nada, que es exactamente lo
    que quieres cuando la petición es <code>POST /orders</code>.
  </p>
  <p>
    Capa de eventos de fxdart, siguiendo a <code>flatMap</code>,
    <code>flatMap(maxConcurrent: 1)</code> y <code>exhaustMap</code> de Rx.
    Al primero se le llama aquí <code>mergeMap</code> porque
    <code><a href="flatMap.html">flatMap</a></code> ya significa aplanar
    iterables en el lado pull.
  </p>

  <h2>Demo 1 · mergeMap — todo a la vez</h2>
  {{playground:0}}

  <h2>Demo 2 · exhaustMap — la protección contra el doble envío</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: el orden de <code>concatMap</code> y un abanico acotado.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — la cuarta política: gana el más nuevo, el resto se cancela ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — abanico acotado del lado pull, donde los resultados mantienen el orden ·
    <a href="debounce.html"><code>debounce</code></a> — a menudo la mejor solución: corta los eventos de más antes de que se conviertan en streams internos
  </div>
