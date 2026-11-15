---
slug: memoizeLast
title: memoizeLast — FxDart 101
description: Tutorial de memoizeLast en FxDart: una caché de una sola ranura indexada por identidad, para funciones puras de estado inmutable, con playground en vivo.
heading: <code>fxMemoizeLast</code>
section: 10
crumb: memoizeLast
prev: memoize.html
prevLabel: memoize
next: negate.html
nextLabel: negate
---
  <p class="hero-sub">Recuerda solo la última llamada — y reconoce una repetición por identidad, en O(1).</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="memoize.html">fxMemoize</a></code> guarda todos los
    argumentos que ha visto alguna vez, indexados por
    <code>==</code>/<code>hashCode</code>. Eso es un error para lo que una app
    quiere cachear con más frecuencia: un valor derivado de un
    <strong>estado inmutable</strong>. Cada cambio crea un objeto de estado
    nuevo, así que una memo sobre el estado crece una entrada por cambio, para
    siempre — y hashear un estado grande en cada llamada puede costar más que
    el trabajo que ahorra.
  </p>
  <p>
    <code>fxMemoizeLast(f)</code> guarda una sola ranura. Una llamada cuyo
    argumento es <code>identical</code> al de la llamada anterior devuelve el
    resultado anterior; cualquier otra ejecuta <code>f</code> y reemplaza la
    ranura. Con estado inmutable eso es exactamente lo correcto: la misma
    instancia significa que nada cambió, una instancia nueva significa que algo
    podría haber cambiado, y la comprobación es una comparación de punteros. Un
    widget que se reconstruye sesenta veces por segundo sobre el mismo estado
    paga <code>f</code> una sola vez.
  </p>
  <p>
    Pasa <code>equals</code> para comparar por valor, o para indexar por un
    record — <code>(state, id)</code> comparado campo a campo — cuando la
    función recibe más de un argumento. Memoiza solo una función cuyo
    resultado dependa únicamente de su argumento: una que además lea el reloj
    o un campo mutable servirá desde la ranura una respuesta obsoleta.
    Extensión de fxdart (sin contraparte en FxTS), inspirada en la memo de
    selectores de reselect.
  </p>

  <h2>Demo 1 · Mismo estado, una ejecución</h2>
  {{playground:0}}

  <h2>Demo 2 · Dos argumentos, y frente a fxMemoize</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: haz que tres llamadas sobre la misma lista ejecuten la función una sola vez.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="memoize.html"><code>fxMemoize</code></a> — una caché de cada argumento ·
    <a href="onChange.html"><code>fxOnChange</code></a> — omite un callback cuyo valor no cambió ·
    <a href="identity.html"><code>fxIdentity</code></a>
  </div>
