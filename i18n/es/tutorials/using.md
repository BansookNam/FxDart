---
slug: using
title: using — FxDart 101
description: Tutorial de using y usingAsync en FxDart: acota un recurso a una iteración perezosa — adquiere en el primer pull, libera exactamente una vez — con playground en vivo.
heading: <code>using</code>
section: 11
crumb: using
prev: timeout.html
prevLabel: timeout
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Acota un recurso a una iteración: adquirido en el primer pull, liberado exactamente una vez — al completar <em>o</em> ante un error.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Archivos, sockets, cursores de base de datos — el valor que producen
    es una secuencia, pero su <em>vida útil</em> es un paréntesis:
    abrir, leer, cerrar, <em>incluso cuando leer lanza una excepción</em>.
    Escribir ese paréntesis alrededor de un pipeline perezoso es
    incómodo, porque «cuando termina la iteración» está allá donde esté
    el consumidor. <code>using(acquire, use, release)</code> ata el
    paréntesis a la iteración misma: <code>acquire</code> corre en el
    primer pull (no al construir el pipeline — la pereza se preserva),
    <code>use(resource)</code> aporta los elementos, y
    <code>release(resource)</code> corre exactamente una vez, tras el
    último elemento o justo antes de que un error se propague.
  </p>
  <p>
    La forma async <code>usingAsync</code> permite que los tres pasos
    sean asíncronos y compone con
    <code><a href="concurrent.html">concurrent</a></code> — release sigue
    disparándose exactamente una vez aunque haya pulls solapados en
    vuelo. Si <code>acquire</code> falla, no hay nada que liberar, y el
    error simplemente se propaga.
  </p>
  <p>
    Una salvedad honesta, directa del modelo pull: un consumidor que
    <em>abandona</em> la iteración — un <code>break</code> dentro de un
    <code>for-in</code>, soltar el iterador — nunca llega al final, así
    que <code>release</code> no puede ejecutarse. Acota la iteración con
    <code><a href="take.html">take</a></code> (un pipeline acotado
    completa, y completar libera) o gestiona el recurso con
    <code>try</code>/<code>finally</code> cuando la salida anticipada sea
    el plan. Extensión de fxdart (sin contraparte en FxTS), inspirada en
    el <code>using</code> de Rx.
  </p>

  <h2>Demo 1 · El paréntesis alrededor de una lectura perezosa</h2>
  {{playground:0}}

  <h2>Demo 2 · Liberación ante error, exactamente una vez</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: dale una vida útil a la conexión.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="take.html"><code>take</code></a> — acota la iteración para garantizar la compleción (y la liberación) ·
    <a href="peek.html"><code>peek</code></a> — observar valores sin poseer una vida útil ·
    <a href="retry.html"><code>retry</code></a> — un acquire nuevo por intento cuando se envuelve en una factoría
  </div>
