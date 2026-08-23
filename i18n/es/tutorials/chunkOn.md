---
slug: chunkOn
title: chunkOn — FxDart 101
description: Tutorial de chunkOn en FxDart: agrupa eventos por cantidad, por un stream disparador o por una ventana de tiempo — convierte un stream parlanchín en pocas llamadas de red — con playground en vivo.
heading: <code>chunk</code>, <code>chunkOn</code> &amp; <code>chunkEvery</code>
section: 14
crumb: chunkOn
prev: stopOn.html
prevLabel: stopOn
next: windowOn.html
nextLabel: windowOn
---
  <p class="hero-sub">Recoge eventos en listas — por cantidad, por disparador o por reloj — para que un stream parlanchín se convierta en unas pocas llamadas agrupadas.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Agrupar es la mejora de rendimiento más barata que tiene un stream
    parlanchín. Cien eventos de analítica son cien viajes de ida y vuelta uno
    a uno, y dos viajes en lotes de cincuenta; el trabajo es idéntico, el
    coste no. La capa pull agrupa por cantidad con
    <code><a href="chunk.html">chunk</a></code>, y eso es todo lo que puede
    hacer: un pipeline pull no tiene reloj, así que «todo lo que ha pasado en
    los últimos dos segundos» no es una pregunta que pueda formular.
  </p>
  <p>
    El lado push sí puede. <code>chunk(count)</code> es esa misma agrupación
    de tamaño fijo, con un último lote corto que se vacía cuando la fuente se
    cierra para que no quede nada varado.
    <code>chunkEvery(window)</code> agrupa por <strong>tiempo</strong> en su
    lugar: lo que haya llegado en la última ventana se emite como una lista. Y
    <code>chunkOn(trigger)</code> entrega la decisión a un segundo stream:
    agrupa cuando el usuario hace scroll, cuando termina el frame, cuando
    vuelve la conexión.
  </p>
  <p>
    Las dos formas gobernadas por el tiempo <strong>callan ante una ventana
    vacía</strong>. Un tic que no encuentra nada acumulado no emite nada en
    lugar de una lista vacía, así que el código de aguas abajo nunca tiene que
    filtrar lotes que significan «no ha pasado nada»: la misma regla de
    honestidad que sigue
    <code><a href="sampleOn.html">sampleOn</a></code>. Lo que siga acumulado
    cuando la fuente se cierre se vacía antes del cierre.
  </p>
  <p>
    Capa de eventos de fxdart, siguiendo a <code>bufferCount</code>,
    <code>buffer</code> y <code>bufferTime</code> de Rx. La familia conserva
    el <code>chunk</code> de la capa pull como palabra raíz —un nombre para
    una idea en las dos mitades de la biblioteca— con el sufijo
    <code>…On</code> para un disparador y <code>…Every</code> para un reloj.
  </p>

  <h2>Demo 1 · Agrupar por reloj</h2>
  {{playground:0}}

  <h2>Demo 2 · Por cantidad y por disparador</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: un resumen por ventana en vez de un informe por clic.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="chunk.html"><code>chunk</code></a> — el original de la capa pull, que agrupa por cantidad sobre un Iterable ·
    <a href="throttle.html"><code>throttle</code></a> — cuando quieres un evento por ventana en vez de todos ·
    <a href="spaceBy.html"><code>spaceBy</code></a> — la otra forma de frenar una ráfaga: estirarla en vez de agruparla
  </div>
