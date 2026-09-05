---
slug: retryOn
title: retryOn — FxDart 101
description: Tutorial de retryOn en FxDart: resuscribirse ante error o ante finalización, con presupuesto de reintentos, un retardo o un notificador — más el teardown de whenComplete — con playground en vivo.
heading: <code>retryOn</code>, <code>repeat</code> &amp; <code>whenComplete</code>
section: 14
crumb: retryOn
prev: debounceOn.html
prevLabel: debounceOn
next: onErrorResume.html
nextLabel: onErrorResume
---
  <p class="hero-sub">Resuscribirse ante error o ante finalización — con un presupuesto, un retardo o un notificador que decide cuándo volver a intentarlo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    El <code><a href="retry.html">retry</a></code> de la capa pull
    reconstruye un iterable. En el lado push la misma idea es una
    <strong>resuscripción</strong>, y hay dos formas. Una reconstruye
    el stream desde una factoría —
    <code><a href="onErrorResume.html">FxEvents.retry</a></code>, ya
    cubierto — que es el movimiento correcto para un
    <code>StreamController</code> de un solo uso. La otra vuelve a
    escuchar el mismo stream, y esa es esta página:
    <code>retryOnError</code>,
    <code>retryOn</code>, <code>repeat</code>, <code>repeatOn</code>.
  </p>
  <p>
    Volver a escuchar necesita una fuente que lo permita.
    <code>Stream.multi</code>, <code>Stream.fromIterable</code> y un
    broadcast lo hacen; un controlador de suscripción única agotado
    fallará en el segundo listen. Acude a
    <code><a href="onErrorResume.html">FxEvents.retry</a></code> (o
    <code>FxEvents.defer</code>) cuando la fuente es de un solo uso.
  </p>
  <p>
    <code>retryOnError({count, delay})</code> resuscribe ante error —
    para siempre cuando <code>count</code> es null, o hasta ese número
    de <em>reintentos</em> (así que <code>count: 2</code> son tres
    intentos). <code>delay</code>, si se define, se consulta con el
    número de reintento empezando en 1 antes de cada reintento. Cuando
    el presupuesto se agota, se reenvía el último error y el stream se
    cierra.
  </p>
  <p>
    <code>retryOn(notifier)</code> es el <code>retryWhen</code> de Rx:
    el error <strong>no</strong> se reenvía; se empuja al
    <code>notifier</code>, y un next de ese stream resuscribe.
    Completar el notificador completa el resultado sin el error; un
    error del notificador se reenvía. <code>repeat</code> /
    <code>repeatOn</code> son el mismo par ante
    <strong>finalización</strong> en vez de error —
    los errores se reenvían y paran. <code>whenComplete</code> es el
    <code>finalize</code> de Rx: el callback corre exactamente una vez
    ante done, error o cancel. Capa de eventos de fxdart, siguiendo a
    <code>retryWhen</code>,
    <code>retry</code>, <code>repeat</code>, <code>repeatWhen</code> y
    <code>finalize</code> de Rx.
  </p>

  <h2>Demo 1 · retryOnError, con retardo</h2>
  {{playground:0}}

  <h2>Demo 2 · Repetir un stream corto dos veces</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: retryOn — el notificador decide cuándo resuscribirse.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="onErrorResume.html"><code>FxEvents.retry</code></a> — la forma con factoría, para fuentes que no puedes volver a escuchar ·
    <a href="retry.html"><code>retry</code></a> — el original de la capa pull, con gancho de backoff y ámbito por elemento ·
    <a href="timeout.html"><code>timeout</code></a> — acota cuánto puede tardar un pull, en vez de cuántas veces reintenta
  </div>
