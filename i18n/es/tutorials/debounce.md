---
slug: debounce
title: debounce — FxDart 101
description: Tutorial de debounce en FxDart: retrasa la llamada a una función hasta que todo se calma, con flanco de subida y cancel(), y playground en vivo.
heading: <code>debounce</code>
section: 12
crumb: debounce
next: throttle.html
nextLabel: throttle
---
  <p class="hero-sub">Retrasa la llamada a una función hasta que pasa wait desde la última llamada — de una ráfaga solo sobrevive la última.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>debounce</code> envuelve un callback para que las llamadas
    repetidas en rápida sucesión se colapsen en una sola. Cada llamada
    reinicia un temporizador de duración <code>wait</code>; la función
    <code>func</code> envuelta solo se dispara de verdad cuando pasa
    <code>wait</code> <em>sin</em> otra llamada — y lo hace con el argumento
    que recibió esa última llamada. Es el patrón clásico de "espera a que el
    usuario deje de teclear antes de buscar".
  </p>
  <p>
    En JS, FxTS engancha un método <code>.cancel()</code> directamente a la
    función devuelta. Las funciones de Dart no pueden llevar miembros extra,
    así que FxDart devuelve un <code>Debounced&lt;T&gt;</code> — una clase con
    un método <code>call(T arg)</code>, que Dart te deja invocar con sintaxis
    normal de llamada a función (<code>debounced(arg)</code>) gracias a la
    convención <code>call()</code>, más un <code>.cancel()</code> explícito
    para descartar cualquier invocación pendiente.
  </p>
  <p>
    Por defecto (<code>leading: false</code>) solo se dispara el flanco
    <strong>de bajada</strong> — la última llamada de la ráfaga, cuando todo
    se calma. Pasa <code>leading: true</code> y será la
    <strong>primera</strong> llamada de la ráfaga la que se dispare de
    inmediato, suprimiendo el resto hasta el siguiente periodo de calma.
  </p>

  <h2>Demo 1 · Flanco de bajada (el valor por defecto)</h2>
  <p>Tres llamadas rápidas se colapsan en una — solo sobrevive el último argumento:</p>
  {{playground:0}}

  <h2>Demo 2 · Flanco de subida y cancel()</h2>
  <p>
    <code>leading: true</code> dispara de inmediato y suprime el resto de la
    ráfaga; <code>.cancel()</code> descarta por completo una llamada de
    bajada pendiente:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: envuelve <code>save</code> en <code>debounce</code> (100 ms de espera)
    para que solo sobreviva el valor final de la ráfaga de llamadas de abajo.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="throttle.html"><code>throttle</code></a> — se dispara a intervalos regulares en lugar de tras la calma ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — para montar demos con temporización ·
    <a href="concurrent.html"><code>concurrent</code></a> — limitar el ritmo de pipelines asíncronos ·
    <a href="shuffle.html"><code>shuffle</code></a> — aleatoriedad con semilla
  </div>
