---
slug: windowed
title: windowed — FxDart 101
description: Tutorial de windowed en FxDart: ventanas deslizantes sobre una secuencia — medias móviles, lotes con solape, detección de rachas — con playground en vivo.
heading: <code>windowed</code>
section: 5
crumb: windowed
prev: chunk.html
prevLabel: chunk
next: pairwise.html
nextLabel: pairwise
---
  <p class="hero-sub">Ventanas deslizantes de <code>size</code> elementos consecutivos, cada una empezando <code>step</code> elementos después de la anterior.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="chunk.html">chunk</a></code> corta una secuencia en
    piezas <em>sin solape</em>. En cuanto las piezas deben solaparse —
    una media móvil, «tres lecturas consecutivas por encima del límite»,
    cualquier pregunta de cada-elemento-con-sus-vecinos — acabas
    escribiendo a mano un bucle con índices y límites delicados.
    <code>windowed(size)</code> es ese bucle como operador perezoso:
    produce una <code>List</code> con cada grupo de <code>size</code>
    elementos consecutivos, deslizándose hacia delante <code>step</code>
    posiciones (1 por defecto) entre ventanas.
  </p>
  <p>
    Dos perillas cubren toda la familia. <code>step</code> espacia las
    ventanas: <code>step&nbsp;&lt;&nbsp;size</code> las solapa,
    <code>step&nbsp;==&nbsp;size</code> las hace encajar exactamente como
    <code>chunk</code>, y <code>step&nbsp;&gt;&nbsp;size</code> muestrea
    dejando huecos. <code>partial:&nbsp;true</code> conserva las ventanas
    más cortas del final en lugar de descartarlas — de hecho
    <code>chunk(n)</code> <em>es</em>
    <code>windowed(n, step:&nbsp;n, partial:&nbsp;true)</code>; comparten
    una única implementación.
  </p>
  <p>
    Extensión de fxdart (sin contraparte en FxTS) — llamada como el
    <code>windowed</code> de Kotlin; quienes vengan de RxDart lo conocen
    como <code>bufferCount(size, startEvery)</code>. Es perezoso como
    todos los operadores de fxdart: las ventanas se materializan pull a
    pull, así que compone con fuentes inagotables y con
    <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · Media móvil</h2>
  {{playground:0}}

  <h2>Demo 2 · Las perillas step y partial</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: marca tres días consecutivos por encima del límite de gasto.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="chunk.html"><code>chunk</code></a> — el caso especial sin solape ·
    <a href="pairwise.html"><code>pairwise</code></a> — ventanas de exactamente dos, como registros ·
    <a href="scan.html"><code>scan</code></a> — estado acumulado sin ventana fija
  </div>
