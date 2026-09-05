---
slug: fxEventsCreate
title: fxEventsCreate — FxDart 101
description: Tutorial de fxEventsCreate en FxDart: construye una cadena de eventos a partir de un valor, un future, un generador o un callback create — con playground en vivo.
heading: constructores
section: 14
crumb: fxEventsCreate
prev: fxEvents.html
prevLabel: fxEvents
next: whenComplete.html
nextLabel: whenComplete
---
  <p class="hero-sub">Constructores fríos para una cadena de eventos: un valor, un cierre vacío, un future, un generador, un callback create — sin un Stream que ya tuvieras que envolver.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="fxEvents.html">fxEvents</a>(stream)</code> envuelve un
    stream que ya tienes. Estos constructores
    <strong>son</strong> el stream. Se mantienen fríos: envolverlos o
    nombrarlos no escucha nada; un terminal
    (<code>toList</code>, <code>head</code>, <code>listen</code>) es
    lo que pone los eventos a fluir. Esa es la misma regla de honestidad
    que el resto de la cadena conserva.
  </p>
  <p>
    Los simples primero. <code>FxEvents.value(x)</code> emite
    <code>x</code> y se cierra — el <code>of</code>/<code>just</code> de
    Rx. <code>FxEvents.empty()</code> se cierra sin nada.
    <code>FxEvents.never()</code> nunca emite y nunca se cierra;
    escuchar cuelga hasta que se cancela, así que es una mención, no una
    demo. <code>fromFuture</code> emite el valor del future (o su error)
    y se cierra; el future no se observa hasta que llega un listener.
    <code>generate(initial, condition, iterate)</code> recorre
    <code>initial, iterate(initial), …</code> mientras la condición se
    cumple — cada paso es un tick de temporizador, así que un generador
    infinito aún puede cancelarse.
  </p>
  <p>
    Tiempo, después factorías. <code>FxEvents.timer(delay)</code> emite
    <code>0</code> tras el retardo y se cierra; con
    <code>every</code> continúa <code>1, 2, …</code> en ese periodo.
    <code>periodic</code> es el reloj que nunca completa
    (conteo de ticks cuando se omite el computation) — cancélalo; no le
    hagas <code>toList</code>. <code>defer(factory)</code> construye un
    stream interior fresco en cada listen — la factoría, no el wrapper;
    la cadena se mantiene de suscripción única. <code>using</code>
    adquiere un recurso al escuchar, lo refleja y lo libera exactamente
    una vez — la contraparte push del
    <code><a href="using.html">using</a></code> pull.
    <code>fromPattern(add, remove)</code> es el puente típico
    <code>on</code>/<code>off</code>. Y
    <code>create(init)</code> llama a <code>init</code> con un
    <code>EventEmitter</code>: <code>add</code>, <code>addError</code>,
    <code>close</code>, y <code>onCancel</code> para el teardown. Un
    throw desde <code>init</code> se reenvía y el stream se cierra.
  </p>
  <p>
    Capa de eventos de fxdart, según el <code>of</code>/<code>just</code>,
    <code>EMPTY</code>, <code>NEVER</code>, <code>from</code>,
    <code>interval</code>, <code>timer</code>, <code>defer</code>,
    <code>generate</code>, <code>fromEventPattern</code>,
    <code>using</code>, y el constructor <code>Observable</code> /
    <code>create</code> de Rx.
  </p>

  <h2>Demo 1 · value, empty, generate</h2>
  {{playground:0}}

  <h2>Demo 2 · defer, y fromFuture</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: un <code>create</code> que emite 1, 2, 3 y luego se cierra.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — envolver un Stream que ya tienes ·
    <a href="using.html"><code>using</code></a> — el original de la capa pull: adquirir en el primer pull, liberar una vez ·
    <a href="share.html"><code>share</code></a> — cuando una ejecución de una cadena necesita muchos listeners
  </div>
