---
slug: sampleOn
title: sampleOn — FxDart 101
description: Tutorial de sampleOn en FxDart: emite el valor más reciente de la fuente cada vez que dispara un stream disparador — desacopla un productor rápido de un consumidor lento — con playground en vivo.
heading: <code>sampleOn</code>
section: 14
crumb: sampleOn
prev: whenComplete.html
prevLabel: whenComplete
next: combineLatest.html
nextLabel: combineLatest
---
  <p class="hero-sub">Emite el valor más reciente de la fuente cada vez que dispara el stream disparador — la fuente pone los valores, el disparador pone el ritmo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un sensor se actualiza doscientas veces por segundo; la pantalla se
    repinta sesenta. Procesar cada actualización es trabajo desperdiciado —
    lo que el consumidor quiere de verdad es <em>el valor más reciente, a su
    propio ritmo</em>. <code>sampleOn(trigger)</code> es exactamente esa
    separación: el stream fuente aporta los valores, el stream disparador
    aporta los momentos, y cada evento del disparador emite el último valor
    de la fuente.
  </p>
  <p>
    Dos detalles lo mantienen honesto. Un disparador que dispara cuando no
    ha llegado nada nuevo se queda en <strong>silencio</strong> — nunca ves
    el mismo valor dos veces seguidas solo porque el reloj hizo tic. Y los
    valores superados entre disparos se <strong>descartan, no se
    encolan</strong>: es un operador con pérdidas por diseño, para streams
    de tipo estado donde solo importa la lectura más reciente.
  </p>
  <p>
    La vida útil sigue a la fuente: cuando la fuente se cierra, la cadena
    se cierra y la suscripción al disparador se cancela — un tic infinito
    de <code>Stream.periodic</code> es un disparador perfectamente válido.
    Compara con los vecinos: <code><a href="throttle.html">throttle</a></code>
    limita la tasa con una ventana fija medida desde los propios eventos de
    la fuente; <code>sampleOn</code> le entrega el calendario por completo a
    un segundo stream. Capa de eventos de fxdart, según el
    <code>sample</code> de Rx.
  </p>

  <h2>Demo 1 · El disparador pone el ritmo</h2>
  {{playground:0}}

  <h2>Demo 2 · Silencio cuando no hay nada nuevo, se cierra con la fuente</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: una posición de arrastre por frame.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="throttle.html"><code>throttle</code></a> — limitación de tasa desde el propio timing de la fuente ·
    <a href="debounce.html"><code>debounce</code></a> — esperar la calma en lugar de muestrear ·
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — la misma idea de «valor más reciente», pero combinando dos streams de datos
  </div>
