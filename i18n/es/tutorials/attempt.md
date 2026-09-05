---
slug: attempt
title: attempt — FxDart 101
description: Tutorial de attempt en FxDart: mueve un error de un stream de Dart al canal de valores como un Left tipado, y vuelve a poner un Left en el canal de errores con raiseLefts — con playground en vivo.
heading: <code>attempt</code> &amp; <code>raiseLefts</code>
section: 14
crumb: attempt
prev: onErrorResume.html
prevLabel: onErrorResume
next: mapEither.html
nextLabel: mapEither
---
  <p class="hero-sub">Mueve un fallo entre los dos canales que tiene un <code>Stream</code> de Dart: el canal de errores que ve todo <code>listen(onError:)</code>, y el canal de valores que lleva <code>Either</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Las propias herramientas de error de la capa de eventos —
    <code><a href="onErrorResume.html">onErrorReturn</a></code>,
    <code>onErrorResume</code>,
    <code><a href="retryOn.html">retryOn</a></code>,
    <code>retryOnError</code> — hablan todas un
    <code>Object</code> sin tipar, porque eso es lo que lleva el canal de
    errores. <code>attempt</code> es el puente hacia la mitad tipada de la
    librería: cada evento de datos se convierte en un <code>Right</code>,
    cada evento de error en un <code>Left</code> construido por
    <code>onThrow</code>. Una vez que el fallo es un <code>Left</code>, el
    compilador conoce su tipo y un <code>switch</code> sobre el evento no
    puede olvidarse de manejarlo.
  </p>
  <p>
    Convierte en el límite de la fuente y quédate después en el canal de
    valores. Un error de Dart no es terminal, así que la fuente mantiene su
    suscripción y los eventos posteriores siguen llegando — la misma razón
    por la que <code>onErrorReturn</code> sustituye <em>por error</em> en
    vez de rescatar una sola vez. La diferencia es el tipo de resultado:
    <code>onErrorReturn</code> conserva <code>T</code> eligiendo un
    marcador de posición; <code>attempt</code> lo cambia a
    <code>Either&lt;E, T&gt;</code> para que el fallo tenga nombre.
  </p>
  <p>
    Coloca <code>attempt</code> <strong>después</strong> de
    <code>retryOn</code> / <code>retryOnError</code> / <code>FxEvents.retry</code>,
    nunca antes. Esos operadores vigilan el canal de errores, y no queda
    nada ahí que reintentar una vez que el error se ha convertido en un
    valor.
  </p>
  <p>
    <code>raiseLefts</code> es la otra dirección, solo sobre fallos
    non-nullable, porque Dart no puede hacer <code>throw</code> de null.
    Desenvuelve cada <code>Right</code> y vuelve a poner cada
    <code>Left</code> en el canal de errores, para un límite que entrega el
    stream a código basado en <code>Stream</code> que espera errores de
    Dart. Un viaje de ida y vuelta <code>attempt</code> /
    <code>raiseLefts</code> conserva el valor del fallo y no su stack
    trace — <code>Left</code> no lleva uno.
  </p>

  <h2>Demo 1 · Los errores se convierten en Left, la cadena sigue</h2>
  {{playground:0}}

  <h2>Demo 2 · raiseLefts, la otra dirección</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: <code>attempt</code> después de retry convierte un fallo
    reintentado; <code>attempt</code> antes de retry no deja nada en el
    canal de errores que reintentar.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="onErrorResume.html"><code>onErrorReturn</code> / <code>onErrorResume</code></a> — recuperar en el canal de errores, sin tipar ·
    <a href="mapEither.html"><code>mapEither</code></a> — quédate en el canal de valores; un raise se convierte en un <code>Left</code> ·
    <a href="either.html"><code>Either</code></a> — el tipo de resultado sellado que envuelven estos operadores
  </div>
