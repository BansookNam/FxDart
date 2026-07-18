---
slug: dropUntil
title: dropUntil — FxDart 101
description: Tutorial de dropUntil en FxDart: omite valores hasta la primera coincidencia incluida y luego emite el resto, con un playground en vivo.
heading: <code>dropUntil</code>
section: 5
crumb: dropUntil
prev: dropWhile.html
prevLabel: dropWhile
next: slice.html
nextLabel: slice
---
  <p class="hero-sub">Omite valores hasta que el predicado se cumple —el elemento coincidente también se descarta— y luego emite el resto.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>dropUntil</code> es la contraparte del lado drop de
    <code>takeUntilInclusive</code> — y ambos tratan su elemento coincidente
    de forma opuesta. <code>dropWhile</code> deja de descartar justo
    <em>antes</em> del elemento que falla, y lo conserva en la salida;
    <code>dropUntil</code> se detiene <em>en</em> el elemento coincidente y
    lo descarta junto con todo lo anterior. Solo sobreviven los elementos
    estrictamente posteriores a la coincidencia.
  </p>
  <p>
    Úsalo cuando un marcador o centinela debe desaparecer junto con el
    prefijo que delimita: "todo lo que va después de la línea <code>READY</code>,
    sin incluir el propio <code>READY</code>".
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Compáralo con <code>dropWhile</code>: aquí el elemento coincidente
    (<code>3</code> / <code>'STOP'</code>) no aparece en el resultado:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: descarta todo hasta <code>'READY'</code>, incluido.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="dropWhile.html"><code>dropWhile</code></a> — conserva el elemento coincidente ·
    <a href="takeUntilInclusive.html"><code>takeUntilInclusive</code></a> — la contraparte del lado take ·
    <a href="drop.html"><code>drop</code></a> — descarta por número fijo
  </div>
