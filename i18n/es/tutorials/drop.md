---
slug: drop
title: drop — FxDart 101
description: Tutorial de drop en FxDart: omite los primeros n valores de un pipeline perezoso, con un playground en vivo.
heading: <code>drop</code>
section: 5
crumb: drop
prev: takeUntilInclusive.html
prevLabel: takeUntilInclusive
next: dropRight.html
nextLabel: dropRight
---
  <p class="hero-sub">Devuelve un iterable perezoso que omite los primeros <code>length</code> valores.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>drop</code> es el opuesto de <code>take</code>: descarta los primeros
    <code>length</code> valores y emite todo lo que venga después. Sigue siendo
    perezoso —no se omite nada hasta que alguien tira realmente del pipeline— y
    funciona sin problemas sobre fuentes infinitas, ya que solo necesita contar
    un número fijo de elementos antes de dejar pasar el resto tal cual.
  </p>
  <p>
    En la cadena <code>Fx</code>, <code>drop</code> también está disponible como
    <code>skip</code>, siguiendo la nomenclatura del propio <code>Iterable.skip</code>
    de Dart (el <code>Fx</code> de FxDart ya extiende <code>Iterable</code>, así que
    ambas grafías resuelven al mismo operador).
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: descarta las 2 primeras líneas de cabecera.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="take.html"><code>take</code></a> — lo contrario, se queda con los primeros n ·
    <a href="dropRight.html"><code>dropRight</code></a> — descarta desde el final ·
    <a href="dropWhile.html"><code>dropWhile</code></a> — descarta según un predicado ·
    <a href="slice.html"><code>slice</code></a> — ventana de índices arbitraria
  </div>
