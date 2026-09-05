---
slug: materialize
title: materialize — FxDart 101
description: Tutorial de materialize en FxDart: StreamEvent (Next, Err, Done), materialize, dematerialize, timestamped, intervals, partition y sequenceEqual — terminales de eventos y sequenceEqual / sequenceEqualAsync en pull — con playground en vivo.
heading: <code>materialize</code>, <code>timestamped</code>, <code>sequenceEqual</code>
section: 14
crumb: materialize
prev: fxSubscriptions.html
prevLabel: FxSubscriptions
next: job-search.html
nextLabel: debounced search
---
  <p class="hero-sub">Reifica notificaciones como <code>Next</code> / <code>Err</code> / <code>Done</code>, sella eventos con tiempo y comprueba si dos secuencias son iguales.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Los tres terminales de un <code>Stream</code> de Dart — un valor, un
    error, un cierre — normalmente abandonan la tubería.
    <code>materialize</code> convierte cada uno en un valor
    <code>StreamEvent</code> que puede viajar
    <em>a través</em> de la cadena: un evento de datos se convierte en
    <code>Next(value)</code>, un error se convierte en <code>Err</code> y
    entonces el resultado <strong>completa</strong> — no falla — y un
    cierre se convierte en <code>Done</code> y entonces el resultado
    completa. Ese es el punto de reificarlos: <code>toList</code> puede
    recolectar un error en vez de fallar, un log puede imprimir
    <code>Err(boom)</code> junto a <code>Next(1)</code>, un test puede
    afirmar la secuencia exacta de notificaciones.
    <code>dematerialize</code> es la inversa —
    <code>Next</code> se convierte en un valor, <code>Err</code> se
    convierte en <code>Stream.addError</code>, <code>Done</code> cierra
    el resultado, y todo lo que venga después de <code>Done</code> se
    ignora. Ida y vuelta:
    <code>materialize().dematerialize()</code> es el stream original de
    valores. Capa de eventos de fxdart, siguiendo a
    <code>materialize</code> /
    <code>dematerialize</code> de Rx.
  </p>
  <p>
    El tiempo es el otro metadato que una notificación puede llevar.
    <code>timestamped</code> empareja cada evento con la hora de reloj
    de pared en la que llegó (<code>(DateTime at, T value)</code>);
    <code>intervals</code> lo empareja con el tiempo desde el anterior
    (<code>(Duration dt, T value)</code>), y el primer evento es siempre
    <code>Duration.zero</code>. Ambos aceptan <code>now:</code> para que
    un test pueda pasar un reloj falso —
    <code>now: () =&gt; DateTime.utc(2020)</code> —
    en vez de <code>DateTime.now</code>. Los errores y el cierre pasan
    sin cambios. Siguiendo a <code>timestamp</code> y
    <code>timeInterval</code> de Rx.
  </p>
  <p>
    <code>partition(test)</code> en eventos no es el
    <code><a href="partition.html">partition</a></code> del lado pull
    (que recorre una vez y devuelve dos listas). Divide una cadena viva
    en <code>(matches, rest)</code> compartiendo <strong>una</strong>
    ejecución de la fuente. El record se devuelve de inmediato; escuchar
    cualquiera de los lados arranca la fuente; un valor que pertenece a
    un lado al que nadie escucha se descarta, no se almacena en búfer.
    Escucha ambos antes de que la fuente dispare si quieres ambas
    mitades.
  </p>
  <p>
    <code>sequenceEqual</code> pregunta si dos secuencias contienen los
    mismos valores en el mismo orden y se detienen juntas. En la capa de
    eventos es un terminal: <code>fxEvents(a).sequenceEqual(b)</code>
    devuelve <code>Future&lt;bool&gt;</code>, false ante el primer valor
    o desajuste de longitud, y un error de cualquiera de los lados hace
    fallar el future. La misma pregunta existe en pull:
    <code>sequenceEqual</code> /
    <code>Fx.sequenceEqual</code> para iterables,
    <code>sequenceEqualAsync</code> /
    <code>FxAsync.sequenceEqual</code> para
    <code>FxAsyncIterable</code>s. Siguiendo a
    <code>sequenceEqual</code> de Rx.
  </p>

  <h2>Demo 1 · Next, Err, Done</h2>
  <p>
    Un cierre limpio se convierte en <code>Done</code>. Un error se
    convierte en <code>Err</code> y entonces la cadena completa — así
    <code>toList</code> devuelve la lista de <code>StreamEvent</code> en
    vez de fallar:
  </p>
  {{playground:0}}

  <h2>Demo 2 · Un reloj que puedes pasar</h2>
  <p>
    <code>now: () =&gt; DateTime.utc(2020)</code> mantiene los sellos
    deterministas. <code>intervals</code> usa el mismo gancho, con un
    reloj que avanza a pasos para que los huecos sean exactos:
  </p>
  {{playground:1}}

  <h2>Demo 3 · sequenceEqual, y partition</h2>
  <p>
    La grafía pull es simplemente <code>fx([1, 2]).sequenceEqual([1, 2])</code>.
    El terminal de eventos toma un <code>Stream</code>. Escucha ambos
    lados de <code>partition</code> antes de que la fuente corra, o la
    mitad no escuchada se descarta:
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — la cadena sobre la que se asientan estos operadores ·
    <a href="streams.html">Puentes de Stream</a> — cuatro formas de tirar de un <code>Stream</code> hacia <code>FxAsync</code> ·
    <a href="partition.html"><code>partition</code></a> — el original del lado pull, dos listas de un solo recorrido ·
    <a href="fxSubscriptions.html"><code>FxSubscriptions</code></a> — cancela un saco de listeners juntos
  </div>
