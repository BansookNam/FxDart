---
slug: cycle
title: cycle — FxDart 101
description: Tutorial de cycle en FxDart: repite una secuencia para siempre — una fuente infinita que siempre debe combinarse con take.
heading: <code>cycle</code>
section: 2
crumb: cycle
prev: repeat.html
prevLabel: repeat
next: entries.html
nextLabel: entries
---
  <p class="hero-sub">Emite una secuencia y luego la repite — para siempre. Combínala siempre con un límite como take.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>cycle</code> es <strong>infinito</strong>: reproduce la secuencia
    fuente una vez, guardando sus valores en un búfer sobre la marcha, y
    después recorre ese búfer en bucle para siempre. A diferencia de todo lo
    demás en esta sección, <code>cycle</code> nunca se agota por su cuenta —
    siempre tienes que combinarlo con algo que decida cuándo parar, casi
    siempre <code>.take(n)</code>. Llamar a <code>toList()</code> o a
    <code>consume()</code> directamente sobre un <code>cycle(...)</code> pelado
    sin un límite en medio se quedará colgado.
  </p>
  <p>
    Un caso límite que conviene conocer: ciclar una fuente <em>vacía</em> no
    emite nada en absoluto, en lugar de dar vueltas eternamente sobre cero
    elementos — así que <code>cycle([])</code> es seguro y simplemente produce
    un resultado vacío.
  </p>
  <p>
    Es una pieza natural para el reparto round-robin (recorrer en ciclo una
    lista corta de trabajadores/colores/huecos mientras haces map sobre una más
    larga) o para repetir una secuencia asíncrona corta y modelar así un bucle
    de sondeo. La forma asíncrona, <code>cycleAsync</code> (o <code>.cycle()</code>
    en una cadena <code>FxAsync</code>), hace el búfer y el bucle igual, pero
    tira de cada vuelta a través del protocolo asíncrono habitual.
  </p>

  <h2>Demo 1 · Infinito, acotado con take</h2>
  {{playground:0}}

  <h2>Demo 2 · Ciclo asíncrono, también acotado con take</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: recorre en ciclo los colores de un semáforo y toma los 8 primeros.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="range.html"><code>range</code></a> — una secuencia de conteo finita ·
    <a href="repeat.html"><code>repeat</code></a> — repite un único valor, un número fijo de veces ·
    <a href="take.html"><code>take</code></a> — el límite que cycle casi siempre necesita ·
    <a href="concurrent.html"><code>concurrent</code></a> — solapa el trabajo de un cycle asíncrono
  </div>
