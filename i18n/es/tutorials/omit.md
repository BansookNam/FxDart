---
slug: omit
title: omit — FxDart 101
description: Tutorial de omit en FxDart: devuelve una copia de un Map sin las claves indicadas, dejando el original intacto.
heading: <code>omit</code>
section: 9
crumb: omit
prev: fromEntries.html
prevLabel: fromEntries
next: pick.html
nextLabel: pick
---
  <p class="hero-sub">Devuelve una copia de un <code>Map</code> sin las claves indicadas.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>omit</code> construye un <code>Map</code> completamente nuevo con todas
    las entradas del original <em>excepto</em> las claves que enumeres — el mapa
    de origen nunca se muta. Las claves de <code>keysToOmit</code> que no existen
    realmente en el mapa se ignoran sin más; no da error por indicar claves
    "de sobra" para eliminar.
  </p>
  <p>
    Es una herramienta habitual para ocultar datos y serializar: quitar el hash de la
    contraseña antes de registrar en el log un objeto de usuario, descartar un campo interno
    antes de enviar una respuesta, y cosas así. Combínalo con <code>map()</code>
    para censurar de golpe una lista entera de mapas.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Censurar una lista entera</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>omit</code> para descartar la clave <code>'debug'</code> de <code>config</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pick.html"><code>pick</code></a> — el inverso: conservar solo algunas claves ·
    <a href="omitBy.html"><code>omitBy</code></a> — descartar por predicado en vez de por lista de claves ·
    <a href="compactObject.html"><code>compactObject</code></a> — descartar las claves con valor null ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — construir un Map desde cero
  </div>
