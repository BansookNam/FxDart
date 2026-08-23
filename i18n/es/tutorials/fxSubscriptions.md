---
slug: fxSubscriptions
title: FxSubscriptions — FxDart 101
description: Tutorial de FxSubscriptions en FxDart: guarda muchas suscripciones a streams en una bolsa y cancélalas, páusalas o reanúdalas juntas — el dispose de una línea — con playground en vivo.
heading: <code>FxSubscriptions</code>
section: 14
crumb: FxSubscriptions
nextLabel: materialize
next: materialize.html
prev: liveValue.html
prevLabel: LiveValue
---
  <p class="hero-sub">Una bolsa de suscripciones, canceladas a la vez — para que el desmontaje sea una llamada en vez de un campo por stream.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un objeto que escucha varios streams tiene que mantener viva cada
    suscripción por un único motivo: volver a cancelarla más tarde. El
    resultado es el montón conocido de campos nullables, cada uno declarado
    arriba, cada uno asignado en <code>initState</code>, cada uno cancelado en
    <code>dispose</code>; y la fuga siempre es la que alguien se olvidó de
    añadir a la tercera lista.
  </p>
  <p>
    <code>FxSubscriptions</code> reduce eso a un solo objeto.
    <code>add</code> mete una suscripción en la bolsa y
    <strong>la devuelve</strong>, así que se lee como una expresión y no como
    una sentencia, y <code>cancelAll()</code> las termina todas. El desmontaje
    se convierte en una sola línea: <code>Future&lt;void&gt; dispose() =&gt;
    subs.cancelAll();</code>
  </p>
  <p>
    <code>pauseAll()</code> y <code>resumeAll()</code> son la versión suave,
    para cuando el trabajo debe pararse sin que se deshaga el cableado: una
    pantalla que pasa a segundo plano, una pestaña que pierde el foco. Las
    suscripciones en pausa almacenan en vez de descartar, así que no se pierde
    nada durante el hueco.
  </p>
  <p>
    La bolsa se vacía <em>antes</em> de esperar sus cancelaciones, así que un
    segundo <code>cancelAll()</code> durante la espera no puede cancelar nada
    dos veces, y el mismo objeto puede albergar después una generación nueva
    de suscripciones. Capa de eventos de fxdart, siguiendo a
    <code>CompositeSubscription</code> de Rx.
  </p>
  <p>
    Se lleva de forma natural con
    <code><a href="stopOn.html">stopOn</a></code>: usa <code>stopOn</code>
    cuando una cadena debe terminar porque algo <em>ha pasado</em>, y
    <code>FxSubscriptions</code> cuando un conjunto de cadenas debe terminar
    porque lo que las poseía <em>se va</em>.
  </p>

  <h2>Demo 1 · El dispose de una línea</h2>
  {{playground:0}}

  <h2>Demo 2 · Pausar sin desmontar</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: <code>addAll</code>, y reutilizar la bolsa después de un cancel.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="stopOn.html"><code>stopOn</code></a> — desmontaje gobernado por un evento en vez de por el ciclo de vida de un propietario ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — la cadena cuyo <code>listen</code> te entrega las suscripciones que esto guarda ·
    <a href="liveValue.html"><code>LiveValue</code></a> — tiene su propio <code>close()</code>, y esta bolsa no lo guarda
  </div>
