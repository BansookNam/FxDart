---
slug: dropRight
title: dropRight — FxDart 101
description: Tutorial de dropRight en FxDart: omite los últimos n valores de un iterable finito, con un playground en vivo.
heading: <code>dropRight</code>
section: 5
crumb: dropRight
prev: drop.html
prevLabel: drop
next: dropWhile.html
nextLabel: dropWhile
---
  <p class="hero-sub">Devuelve un iterable perezoso que omite los últimos <code>length</code> valores.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>dropRight</code> omite los últimos <code>length</code> valores en lugar
    de los primeros. Igual que con <code>takeRight</code>, no hay forma de saber
    qué elementos son los "últimos" sin ver la fuente entera, así que
    <code>dropRight</code> la <strong>materializa</strong> en una lista antes de
    emitir nada. Es la herramienta adecuada cuando tienes, por ejemplo, un lote de
    tamaño conocido y quieres todo salvo un pie o un centinela final — pero
    necesita una fuente finita.
  </p>
  <p>
    <code>dropRightAsync</code> tiene la misma restricción: espera a todo lo que
    hay aguas arriba antes de poder empezar a producir valores.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono (primero hay que almacenar toda la fuente en memoria)</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: descarta las 2 últimas líneas del pie.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="drop.html"><code>drop</code></a> — descarta desde el principio ·
    <a href="takeRight.html"><code>takeRight</code></a> — se queda con los últimos n en vez de descartarlos ·
    <a href="reverse.html"><code>reverse</code></a> — también materializa la fuente
  </div>
