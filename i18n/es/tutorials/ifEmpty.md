---
slug: ifEmpty
title: ifEmpty — FxDart 101
description: Tutorial de ifEmpty y defaultIfEmpty en FxDart: respaldos perezosos para pipelines que resultan estar vacíos, con playground en vivo.
heading: <code>ifEmpty</code>
section: 6
crumb: ifEmpty
prev: fork.html
prevLabel: fork
next: reduce.html
nextLabel: reduce
---
  <p class="hero-sub">Cambia a un respaldo cuando el pipeline resulta estar vacío — decidido perezosamente, en el momento de iterar.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un pipeline que <em>podría</em> no producir nada suele forzar un
    desvío: materializarlo, comprobar <code>isEmpty</code>, ramificar.
    Eso rompe la cadena y — peor — ejecuta el pipeline antes de lo que
    querías. <code>ifEmpty(fallback)</code> pliega esa rama dentro del
    propio pipeline: los valores pasan intactos, y solo si la fuente
    termina sin producir nada toma el relevo el iterable de respaldo. La
    función de respaldo ni siquiera se <em>llama</em> en caso contrario —
    perezoso en ambas direcciones.
  </p>
  <p>
    <code>defaultIfEmpty(value)</code> es el atajo de un solo valor: la
    fila de relleno, el <code>0</code> para un informe vacío, el marcador
    de «sin resultados». Ambos componen en cualquier punto de la cadena,
    lo cual importa tras un filtrado agresivo — la vacuidad la decide lo
    que llegue hasta este punto, no la fuente original.
  </p>
  <p>
    Extensión de fxdart (sin contraparte en FxTS), inspirada en
    <code>switchIfEmpty</code> / <code>defaultIfEmpty</code> de Rx. Las
    formas async aceptan una cadena de respaldo asíncrona y un valor por
    defecto en <code>Future</code>, y componen con
    <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · Un valor por defecto para el informe vacío</h2>
  {{playground:0}}

  <h2>Demo 2 · Fuente de respaldo, jamás tocada si no hace falta</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: busca con una consulta de respaldo.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="filter.html"><code>filter</code></a> — la razón habitual de que una cadena acabe vacía ·
    <a href="concat.html"><code>concat</code></a> — anexar incondicionalmente ·
    <a href="head.html"><code>head</code></a> — <code>null</code> en lugar de un respaldo, para un único valor
  </div>
