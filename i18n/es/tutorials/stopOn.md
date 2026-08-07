---
slug: stopOn
title: stopOn — FxDart 101
description: Tutorial de stopOn en FxDart: termina una cadena de eventos cuando otro stream dispara, y startOn para abrirla — compuertas de cancelación para feeds en vivo — con playground en vivo.
heading: <code>stopOn</code> &amp; <code>startOn</code>
section: 14
crumb: stopOn
prev: waitAll.html
prevLabel: waitAll
next: chunkOn.html
nextLabel: chunkOn
---
  <p class="hero-sub">Dos compuertas gobernadas por un segundo stream: <code>stopOn</code> cierra la cadena cuando el disparador salta, <code>startOn</code> la abre.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Una cadena push no tiene un final natural. Un pipeline pull para cuando
    el consumidor deja de pedir, pero un feed en vivo — un socket, un sensor,
    un <code>Stream.periodic</code> — sigue produciendo hasta que algo lo
    <em>cancela</em>. Olvidarse de hacerlo es la fuga clásica: se destruye una
    pantalla, el widget ya no está, y su suscripción sigue despierta, sigue
    reservando memoria, sigue llamando a <code>setState</code> sobre un
    cadáver.
  </p>
  <p>
    <code>stopOn(trigger)</code> convierte el apagado en parte de la cadena en
    vez de en una variable que tienes que acordarte de cancelar. El primer
    evento de <code>trigger</code> cierra la salida y cancela
    <strong>las dos</strong> suscripciones: la de la fuente y la del
    disparador. No se lee nada de lo que lleve el disparador, solo que
    disparó, así que su tipo es <code>Stream&lt;void&gt;</code> y sirve
    cualquier stream.
  </p>
  <p>
    <code>startOn(trigger)</code> es el espejo: los eventos de la fuente se
    <strong>descartan</strong> hasta que el disparador salta una vez, y a
    partir de ahí pasan para siempre. Es la compuerta de «espera a estar
    listo»: no actúes sobre los toques hasta que la sesión haya cargado. Ojo,
    no tiene relación con <code><a href="fxEvents.html">startWith</a></code>,
    que antepone un valor en lugar de controlar el arranque; los dos nombres
    quedan cerca y significan cosas bastante distintas.
  </p>
  <p>
    El sufijo <code>…On</code> es el convenio de la capa de eventos para
    «gobernado por un stream disparador», compartido con
    <code><a href="sampleOn.html">sampleOn</a></code> y
    <code><a href="chunkOn.html">chunkOn</a></code>. Capa de eventos de
    fxdart, siguiendo a <code>takeUntil</code> y <code>skipUntil</code> de Rx:
    los nombres difieren porque <code>Fx.takeUntil</code> ya significa el
    <code>takeUntilInclusive</code> gobernado por predicado del lado pull, y
    un nombre no puede significar dos cosas en una misma biblioteca.
  </p>

  <h2>Demo 1 · El interruptor de apagado</h2>
  {{playground:0}}

  <h2>Demo 2 · El interruptor de encendido</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: una ventana de sesión, construida con las dos compuertas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fxSubscriptions.html"><code>FxSubscriptions</code></a> — la otra mitad del desmontaje: cancelar muchas suscripciones a la vez ·
    <a href="sampleOn.html"><code>sampleOn</code></a> — el mismo convenio de disparador, para leer en vez de parar ·
    <a href="race.html"><code>race</code></a> — cancelación decidida por quien hable primero
  </div>
