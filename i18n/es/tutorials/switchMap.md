---
slug: switchMap
title: switchMap — FxDart 101
description: Tutorial de switchMap en FxDart: mapea cada evento a un stream interno y refleja solo el más nuevo — cancelación por novedad para cajas de búsqueda — con playground en vivo.
heading: <code>switchMap</code>
section: 14
crumb: switchMap
prev: withLatestFrom.html
prevLabel: withLatestFrom
next: race.html
nextLabel: race
---
  <p class="hero-sub">Mapea cada evento a un stream interno y refleja solo el más nuevo — un evento fresco <em>cancela</em> el stream interno anterior en pleno vuelo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    El bug de la caja de búsqueda que toda UI ha enviado al menos una vez:
    el usuario teclea <code>da</code>, luego <code>dart</code>; la petición
    de <code>da</code> es más lenta; sus resultados obsoletos llegan los
    últimos y pisan los buenos. La solución no es <em>ignorar</em> la
    respuesta vieja sino hacerla imposible: <code>switchMap(f)</code> mapea
    cada evento a un stream interno y, en el momento en que llega un evento
    más nuevo, <strong>cancela</strong> de raíz el stream interno anterior.
    Solo el stream interno más nuevo se refleja aguas abajo.
  </p>
  <p>
    La cancelación por novedad es una política, y es la correcta exactamente
    cuando el trabajo viejo se vuelve <em>inútil</em> en cuanto existe
    entrada más nueva — búsqueda, autocompletado, navegación, «cargar los
    detalles de la fila seleccionada». Es la equivocada cuando la salida de
    cada stream interno importa (una subida por archivo, digamos) — ese es
    un trabajo de fan-out para el
    <code><a href="mapConcurrent.html">mapConcurrent</a></code> del lado
    pull, donde nada se cancela.
  </p>
  <p>
    Semántica en los bordes: la cadena se cierra cuando la fuente se ha
    cerrado <em>y</em> el último stream interno completa — que la fuente
    termine nunca corta el trabajo que ya está en pantalla. Un mapper que
    lanza se convierte en un evento de error y la fuente sigue adelante.
    Capa de eventos de fxdart, según el <code>switchMap</code> de Rx.
  </p>

  <h2>Demo 1 · La caja de búsqueda, arreglada</h2>
  {{playground:0}}

  <h2>Demo 2 · El último stream interno termina de decir lo suyo</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: autocompletado que no puede mostrar sugerencias obsoletas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="debounce.html"><code>debounce</code></a> — su pareja natural aguas arriba: menos consultas de entrada, cero resultados obsoletos de salida ·
    <a href="race.html"><code>race</code></a> — cancelación entre streams <em>hermanos</em> en lugar de sucesivos ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — cuando cada resultado importa, fan-out del lado pull
  </div>
