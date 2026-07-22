---
slug: min
title: min — FxDart 101
description: Tutorial de min en FxDart: el número más pequeño de un pipeline, +infinito cuando está vacío, envenenado por NaN, con playground en vivo.
heading: <code>min</code>
section: 7
crumb: min
prev: averageBy.html
prevLabel: averageBy
next: max.html
nextLabel: max
---
  <p class="hero-sub">El número más pequeño del pipeline, con las rarezas exactas de FxTS ante entradas vacías y <code>NaN</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>min</code> es un fold terminal, solo numérico: internamente es
    <code>fold(double.infinity, ..., iterable)</code>, y compara cada elemento
    contra un mínimo acumulado que empieza en <code>+infinity</code>.
  </p>
  <p>
    Merece la pena memorizar dos comportamientos, porque sorprenden a quien
    viene de una API «segura» y están portados <strong>fielmente desde FxTS</strong>:
  </p>
  <ul>
    <li>
      Un iterable <strong>vacío</strong> devuelve <code>double.infinity</code>:
      ni <code>null</code>, ni un error. Es simplemente el valor inicial del fold
      cuando nada llega a superarlo.
    </li>
    <li>
      Un solo <code>NaN</code> en cualquier punto del iterable
      <strong>envenena</strong> todo el resultado y lo convierte en <code>NaN</code>: toda
      comparación contra <code>NaN</code> es falsa, así que en cuanto pasa a ser el mínimo
      acumulado (o aparece como candidato), se queda en <code>NaN</code> para siempre.
    </li>
  </ul>
  <p>
    Si lo que necesitas es la semántica «el más pequeño, o <code>null</code> si está vacío»,
    comprueba tú mismo <code>result.isInfinite</code>, o recurre a
    <code><a href="find.html">find</a></code> /
    <code><a href="reduce.html">reduce</a></code> con tu propio comparador.
  </p>

  <h2>Demo 1 · Fundamentos, vacío y NaN</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: encuentra el precio <strong>más barato</strong> entre los productos.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="max.html"><code>max</code></a> — la imagen especular ·
    <a href="sum.html"><code>sum</code></a> · <a href="average.html"><code>average</code></a> — los otros terminales numéricos ·
    <a href="find.html"><code>find</code></a> — para una búsqueda del «menor que coincide» a prueba de nulls
  </div>
