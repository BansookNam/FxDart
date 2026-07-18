---
slug: fromEntries
title: fromEntries — FxDart 101
description: Tutorial de fromEntries en FxDart: construye un Map a partir de records (clave, valor), el inverso de entries().
heading: <code>fromEntries</code>
section: 9
crumb: fromEntries
prev: predicates.html
prevLabel: predicates
next: omit.html
nextLabel: omit
---
  <p class="hero-sub">Construye un <code>Map</code> a partir de un iterable de records <code>(key, value)</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Esta sección porta las utilidades de objeto de FxTS, y lo primero que hay
    que entender es la correspondencia: los objetos planos de TypeScript pasan
    a ser <code>Map</code>s de Dart en todas partes, y las tuplas de entrada
    <code>[key, value]</code> de TS pasan a ser records <code>(K, V)</code> de
    Dart. <code>fromEntries</code> es el lado constructor de eso: dale
    cualquier iterable de records y los pliega en un <code>Map</code>, y
    en las claves duplicadas gana la última escritura — exactamente igual que
    si construyeras el map a mano con un bucle.
  </p>
  <p>
    Es la pareja natural de <a href="entries.html"><code>entries</code></a>
    (que hace lo contrario: <code>Map</code> → records) y combina de maravilla
    con <a href="zip.html"><code>zip</code></a>, que convierte dos listas
    paralelas exactamente en la forma de record que <code>fromEntries</code>
    espera.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Claves duplicadas, e ida y vuelta con <code>entries</code></h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>fromEntries</code> para convertir <code>pairs</code> en un <code>Map</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="entries.html"><code>entries</code></a> — la dirección inversa ·
    <a href="zip.html"><code>zip</code></a> — construir entradas a partir de dos listas paralelas ·
    <a href="omit.html"><code>omit</code></a> — descartar claves del Map resultante ·
    <a href="pick.html"><code>pick</code></a> — quedarte solo con algunas claves
  </div>
