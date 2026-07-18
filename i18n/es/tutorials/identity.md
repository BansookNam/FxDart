---
slug: identity
title: identity — FxDart 101
description: Tutorial de identity en FxDart: la función que devuelve su argumento sin tocarlo, y por qué resulta útil como retrollamada por defecto.
heading: <code>identity</code>
section: 10
crumb: identity
prev: matches.html
prevLabel: matches
next: always.html
nextLabel: always
---
  <p class="hero-sub">Devuelve su argumento sin modificarlo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>identity</code> es la función más simple de la librería, y una de
    las más útiles: recibe un valor y lo devuelve tal cual. Por sí sola
    parece inútil. Su valor aparece siempre que una API <em>espera una
    función</em> pero en realidad no quieres transformar nada: una
    función clave por defecto para <code>groupBy</code>/<code>sortBy</code>, una
    rama de relleno en una tabla de despacho o el brazo «no hace nada» de un
    pipeline condicional.
  </p>
  <p>
    Como <code>identity</code> es genérica (<code>T identity&lt;T&gt;(T a)</code>),
    encaja en cualquier hueco que pida una función unaria sin que tengas que escribir
    <code>(x) => x</code> a mano. No tiene variante asíncrona ni forma de
    cadena: es una función corriente de valor a valor que pasas de un lado a otro.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Usada directamente y como función clave de una agrupación en la que
    «agrupar por el propio valor» es justo lo que quieres:</p>
  {{playground:0}}

  <h2>Demo 2 · Como la rama que «no hace nada»</h2>
  <p>
    Una tabla de despacho de transformaciones de cadenas de texto, en la que una entrada no hace
    nada a propósito: <code>identity</code> ocupa ese hueco limpiamente, sin
    escribir una lambda vacía a mano:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: <code>sortBy</code> recibe una función clave. Usa <code>identity</code>
    como esa clave para ordenar esta lista de palabras por su orden natural (alfabético).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="always.html"><code>always</code></a> — una constante en vez de dejar pasar el valor ·
    <a href="tap.html"><code>tap</code></a> — deja pasar el valor, pero antes ejecuta un efecto secundario ·
    <a href="cases.html"><code>cases</code></a> — tabla de despacho con predicados ·
    <a href="sortBy.html"><code>sortBy</code></a> — un destino habitual para una función clave
  </div>
