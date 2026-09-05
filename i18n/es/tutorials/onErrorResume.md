---
slug: onErrorResume
title: onErrorResume — FxDart 101
description: Tutorial de onErrorResume en FxDart: sustituye un valor por cada error, cambia a un stream alternativo o reconstruye el stream entero con retry — con playground en vivo.
heading: <code>onErrorReturn</code>, <code>onErrorResume</code> &amp; <code>retry</code>
section: 14
crumb: onErrorResume
prev: retryOn.html
prevLabel: retryOn
next: attempt.html
nextLabel: attempt
---
  <p class="hero-sub">Tres profundidades de recuperación: parchear cada error con un valor, abandonar la fuente por una alternativa, o tirar el stream entero y reconstruirlo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Los errores se comportan de otra forma en el lado push, y la diferencia
    hace tropezar. En un pipeline pull una excepción termina la iteración: hay
    un fallo y después nada. En un <code>Stream</code> de Dart un error es
    solo otro <strong>evento</strong>: se entrega y la suscripción continúa.
    Un stream puede emitir diez errores y cuarenta valores y aun así cerrarse
    con normalidad.
  </p>
  <p>
    Por eso <code>onErrorReturn(value)</code> es una
    <em>sustitución por error</em> y no un rescate de una sola vez. Cada error
    se convierte en un evento <code>value</code> y el stream sigue adelante:
    lo correcto para un sensor inestable, donde una lectura mala debería
    convertirse en un marcador de posición y el feed debería sobrevivir.
  </p>
  <p>
    <code>onErrorResume(f)</code> es el cambio de una sola vez. Al
    <strong>primer</strong> error la fuente se cancela de golpe y el stream
    que <code>f</code> construye a partir de ese error toma el relevo para
    siempre: la jugada de tirar de caché cuando falla la red. No se vuelve a
    ver nada de la fuente original, y un error lanzado por el propio
    <code>f</code> se reenvía en vez de tragarse.
  </p>
  <p>
    <code>FxEvents.retry(factory, [count])</code> trabaja un nivel más arriba:
    no parchea los errores de un stream, <strong>reconstruye el stream</strong>.
    Ante un error se tira el intento fallido y se vuelve a llamar a
    <code>factory()</code> para una suscripción nueva: la forma correcta
    cuando el fallo es la conexión misma. El presupuesto cuenta
    <em>re</em>suscripciones, así que <code>count: 2</code> permite tres
    intentos como mucho; cuando se agota, el último error se reenvía y el
    stream se cierra. Los eventos que un intento ya emitió no se retiran, así
    que la factoría debería producir algo reproducible.
  </p>
  <p>
    Capa de eventos de fxdart, siguiendo a <code>onErrorReturn</code>,
    <code>onErrorResume</code> y <code>Rx.retry</code> de Rx. Para fallos que
    quieres <em>modelar</em> en vez de recuperar,
    <code><a href="attempt.html">attempt</a></code> los mueve al canal de
    valores como un <code>Left</code> tipado — el puente de la capa de
    eventos hacia <code><a href="either.html">Either</a></code> y
    <code><a href="raise.html">Raise</a></code>.
  </p>

  <h2>Demo 1 · Un valor por error</h2>
  {{playground:0}}

  <h2>Demo 2 · Abandonar la fuente por una alternativa</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: reconstruir un stream inestable, con y sin presupuesto.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="retry.html"><code>retry</code></a> — el original de la capa pull, con gancho de backoff y ámbito por elemento ·
    <a href="attempt.html"><code>attempt</code></a> — los mismos fallos, como <code>Left</code>s tipados en el canal de valores ·
    <a href="either.html"><code>Either</code></a> — errores como valores con tipo en vez de eventos de los que recuperarse
  </div>
