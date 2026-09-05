---
slug: windowOn
title: windowOn — FxDart 101
description: Tutorial de windowOn en FxDart: streams vivos anidados — ventana por cantidad, por un disparador o por un reloj, y ver valores antes de que la ventana cierre — con playground en vivo.
heading: <code>windowOn</code>, <code>windowCount</code> &amp; <code>windowEvery</code>
section: 14
crumb: windowOn
prev: chunkOn.html
prevLabel: chunkOn
next: groupsBy.html
nextLabel: groupsBy
---
  <p class="hero-sub">Streams vivos anidados: ve los valores de una ventana antes de que cierre, rota por cantidad, por un disparador o por un reloj.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="chunkOn.html">chunk</a></code> espera a que una ventana
    cierre y entonces emite una <code>List</code>. La familia <code>window*</code>
    emite la ventana <strong>mientras sigue abierta</strong>: cada
    valor del stream externo es un
    <code>FxEvents</code> anidado, así que un suscriptor puede ver eventos antes del
    cierre — un gráfico en vivo del minuto actual, un total acumulado del
    lote actual. Esa es toda la diferencia, y es por lo que el
    tipo de retorno es <code>FxEvents&lt;FxEvents&lt;T&gt;&gt;</code>.
  </p>
  <p>
    <code>windowCount(size)</code> rota cada <code>size</code>
    eventos; un <code>startEvery</code> menor que <code>size</code>
    solapa, uno mayor deja huecos. <code>windowOn(boundaries)</code> abre una
    ventana de inmediato al escuchar y rota en cada valor disparador —
    se ignora la finalización del límite, así que la ventana actual sigue abierta
    hasta que la fuente completa. <code>windowEvery(span)</code> es la
    forma reloj; <code>every</code> solapa o deja huecos en ese periodo, y
    <code>maxSize</code> cierra una ventana antes por cantidad.
  </p>
  <p>
    La vida útil sigue a RxJS 9: <strong>cancelar el externo completa los internos vivos
    en silencio</strong> en vez de darles error, así que los suscriptores
    anidados se desmontan limpiamente. Un error de la fuente sigue dando error a cada
    interno vivo, y después al externo. Y como los internos son streams, puede
    aparecer una ventana vacía al final cuando se abre una nueva al llenar
    la anterior el último valor — <code>chunk*</code> se salta esas;
    <code>window*</code> no.
  </p>
  <p>
    <code>chunkToggle(openings, closeOf)</code> es la contraparte de la familia lista
    de <code>windowToggle</code>: cada apertura arranca un
    búfer, el primer evento de <code>closeOf</code> de esa apertura
    lo emite, los búferes vacíos se saltan como
    <code><a href="chunkOn.html">chunkOn</a></code>. Capa de eventos de fxdart,
    siguiendo a <code>window</code>, <code>windowCount</code>,
    <code>windowTime</code> y <code>bufferToggle</code> de Rx.
  </p>

  <h2>Demo 1 · Ventanas de dos</h2>
  {{playground:0}}

  <h2>Demo 2 · Rotar con un disparador</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: internos vivos que abarcan un Duration corto.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="chunkOn.html"><code>chunk</code> / <code>chunkOn</code></a> — las mismas ventanas como listas, emitidas cuando cierran ·
    <a href="windowed.html"><code>windowed</code></a> — listas deslizantes en la capa pull ·
    <a href="groupsBy.html"><code>groupsBy</code></a> — internos vivos con clave por valor, no por tiempo
  </div>
