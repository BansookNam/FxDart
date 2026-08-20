---
slug: foldByOrSkip
title: foldByOrSkip — FxDart 101
description: Tutorial de foldByOrSkip en FxDart: filtra y reduce por clave en una sola llamada estricta cuyo callback el compilador sí puede insertar, con un playground en vivo.
heading: <code>foldByOrSkip</code>
section: 7
crumb: foldByOrSkip
prev: foldBy.html
prevLabel: foldBy
next: countWhere.html
nextLabel: countWhere
---
  <p class="hero-sub">Reduce por clave como <code>foldBy</code>, salvo que una clave <code>null</code> salta el elemento — así un solo callback selecciona y clasifica.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>foldByOrSkip(key, seed, f, xs)</code> es
    <code><a href="filter.html">filter</a></code> +
    <code><a href="foldBy.html">foldBy</a></code> escrito como una única
    llamada estricta. Todo lo que <code>foldBy</code> garantiza sigue en pie:
    <code>seed</code> inicia cada clave en lugar de arrastrarse entre ellas,
    las claves salen en orden de primera aparición y el mapa se consulta una
    vez por elemento. La única vuelta de tuerca es la función de clave:
    devolver <code>null</code> significa «salta este elemento», la misma forma
    <code>filter_map</code> que usa
    <code><a href="takeUniqBy.html">takeUniqBy</a></code>.
  </p>
  <p>
    Escribe <code>filter(...).foldBy(...)</code> por defecto. Dos pasos con
    nombre se leen mejor que un callback respondiendo a dos preguntas, y aquí
    esas dos preguntas suelen no tener relación: un rango de fechas y una
    categoría no son la misma idea. Este operador existe por un solo motivo, y
    conviene saber cuál es.
  </p>

  <h2>Por qué existe: el predicado que el compilador no puede ver</h2>
  <p>
    <code>filter</code> es una etapa <em>perezosa</em>, así que guarda su
    predicado en un campo del iterador. El compilador AOT no puede ver a través
    de un campo, de modo que ese predicado nunca se inserta: cada elemento paga
    una llamada indirecta real y su cuerpo jamás se funde con el bucle que lo
    rodea. <code>foldBy</code> no tiene ese problema: es estricto, así que sus
    callbacks son parámetros y sí se insertan. Lo que cuesta es el filtro que
    va delante.
  </p>
  <p>
    <code>foldByOrSkip</code> mueve la prueba dentro de la clave, que es un
    parámetro. Medido sobre 1.000.000 de transacciones, AOT, conservando un mes
    de doce:
  </p>
  <table>
    <thead><tr><th>Forma</th><th>Tiempo</th></tr></thead>
    <tbody>
      <tr><td><code>filter().foldBy()</code></td><td>14,5 ms</td></tr>
      <tr><td><code>foldByOrSkip(…)</code></td><td><strong>12,6 ms</strong></td></tr>
      <tr><td>un bucle escrito a mano</td><td>11,3 ms</td></tr>
    </tbody>
  </table>
  <p>
    Ambas formas, y ambas barras, están en
    <a href="../DartComparison/monthly-category-report.html">Informe mensual
    por categoría</a>: una de las dos páginas de comparación que publican tres
    barras en lugar de dos, porque la diferencia entre dos maneras de escribir
    la misma tubería es precisamente lo que quieren mostrar.
  </p>

  <h2>Demo 1 · El gasto de julio por categoría</h2>
  {{playground:0}}

  <h2>Demo 2 · La semilla, el salto y lo que ve el fold</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: la lectura más alta por sensor, ignorando las filas defectuosas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="foldBy.html"><code>foldBy</code></a> — la reducción sobre la que se apoya ·
    <a href="filter.html"><code>filter</code></a> — la etapa que absorbe ·
    <a href="takeUniqBy.html"><code>takeUniqBy</code></a> — la misma idea para <code>filter</code> + <code>uniqBy</code> + <code>take</code> ·
    <a href="performance.html">Rendimiento</a> — de dónde sale el suelo de los callbacks
  </div>
