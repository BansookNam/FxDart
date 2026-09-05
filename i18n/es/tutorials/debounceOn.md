---
slug: debounceOn
title: debounceOn — FxDart 101
description: Tutorial de debounceOn en FxDart: tiempo impulsado por selector — debounce, delay y throttle cuya ventana de calma es un stream por valor, no un Duration — con playground en vivo.
heading: <code>debounceOn</code>, <code>delayOn</code> &amp; <code>throttleOn</code>
section: 14
crumb: debounceOn
prev: spaceBy.html
prevLabel: spaceBy
next: retryOn.html
nextLabel: retryOn
---
  <p class="hero-sub">Tiempo impulsado por selector: cada valor nombra el stream que decide cuándo le toca — debounce, delay y throttle sin un Duration.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Las formas con Duration ya viven en
    <code><a href="debounce.html">debounce</a></code>,
    <code><a href="throttle.html">throttle</a></code> y
    <code><a href="spaceBy.html">delay</a></code> — un reloj fijo, la
    misma espera para cada valor. La familia <code>xOn</code> entrega
    ese reloj a un <strong>selector</strong>: cada valor produce un
    stream, y el primer evento de ese stream es el momento en que el
    valor toca. Espera un blur en vez de 300ms; debounce consultas más
    largas durante más tiempo; libera un valor retenido cuando dispara
    un botón en vez de cuando lo hace un temporizador.
  </p>
  <p>
    <code>debounceOn(selector)</code> es debounce de flanco de bajada
    con ese stream como ventana de calma. Un valor más nuevo
    <strong>aborta</strong> el interior anterior y arranca uno fresco;
    el primer next del interior emite el valor pendiente; un interior
    que completa sin un next lo <strong>descarta</strong>. Un valor aún
    pendiente cuando la fuente se cierra se vacía, igual que el
    <code><a href="debounce.html">debounce</a></code> con Duration.
  </p>
  <p>
    <code>delayOn(selector)</code> retiene <em>cada</em> valor hasta que
    su propio interior dispara — nada se aborta, así que dos valores en
    vuelo pueden adelantarse si sus selectores lo hacen, igual que el
    <code>delayWhen</code> de Rx. El cierre espera a los interiores
    pendientes; los errores se reenvían de inmediato, ya que solo los
    datos merecen retenerse.
  </p>
  <p>
    <code>throttleOn(selector)</code> emite como máximo un evento por
    ventana interior: <code>leading</code> (activado por defecto, como
    la forma stream de throttle) conserva el primero de la ventana;
    <code>trailing</code> conserva el más reciente visto cuando el
    interior dispara, o cuando la fuente se cierra a mitad de ventana.
    Capa de eventos de fxdart, según las formas con selector de
    <code>debounce</code>, <code>delayWhen</code> y
    <code>throttle</code> de Rx.
  </p>

  <h2>Demo 1 · Una ráfaga, liberada cuando dispara su selector</h2>
  {{playground:0}}

  <h2>Demo 2 · Retenido hasta que un notificador diga adelante</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: un offset de scroll por ventana interior, flanco de subida.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="debounce.html"><code>debounce</code></a> — la forma con Duration, y el wrapper de callback ·
    <a href="throttle.html"><code>throttle</code></a> — la forma con Duration, leading y trailing ·
    <a href="spaceBy.html"><code>delay</code></a> — desplazar un stream entero con un reloj fijo
  </div>
