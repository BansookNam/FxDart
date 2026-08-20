---
slug: takeUniqBy
title: takeUniqBy — FxDart 101
description: Tutorial de takeUniqBy en FxDart: filtra, deduplica y trunca en una sola llamada estricta cuyo callback el compilador sí puede insertar, con un playground en vivo.
heading: <code>takeUniqBy</code>
section: 4
crumb: takeUniqBy
prev: uniqAdjacent.html
prevLabel: uniqAdjacent
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">Los primeros <em>count</em> elementos cuya clave es nueva, como lista — una clave <code>null</code> se salta el elemento, así que un solo callback selecciona y da la clave.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>takeUniqBy(3, key, xs)</code> es
    <code><a href="filter.html">filter</a></code> +
    <code><a href="uniqBy.html">uniqBy</a></code> +
    <code><a href="take.html">take</a></code> escrito como una única llamada
    estricta. Devuelve una <code>List</code>, se ejecuta cuando la llamas y se
    detiene en cuanto alcanza la cuenta: los elementos posteriores nunca se
    inspeccionan. La única vuelta de tuerca es el callback: devuelve una clave,
    y devolver <code>null</code> significa «salta este elemento». Esa es la
    forma <code>filter_map</code>, y es lo que permite que una sola función
    haga el trabajo de dos.
  </p>
  <p>
    Escribe la cadena por defecto. Tres pasos con nombre se leen mejor que un
    callback respondiendo a dos preguntas, y la cadena perezosa corta igual de
    bien. Este operador existe por un solo motivo, y conviene saber cuál es.
  </p>

  <h2>Por qué existe: el callback que el compilador no puede ver</h2>
  <p>
    Una etapa perezosa guarda su callback en un <em>campo del iterador</em>. El
    compilador AOT no puede ver a través de un campo, así que el closure nunca
    se inserta: cada elemento paga una llamada indirecta real y su cuerpo jamás
    se funde con el bucle que lo rodea. Dos etapas, dos llamadas por elemento.
    Eso es la mayor parte de lo que separa una cadena idiomática de FxDart de
    un bucle escrito a mano.
  </p>
  <p>
    <code>takeUniqBy</code> recibe su callback como <em>parámetro</em> de un
    cuerpo lo bastante pequeño para insertarse en el punto de llamada, así que
    el compilador inserta con él el cuerpo del closure. Medido sobre 1.000.000
    de líneas de log, AOT:
  </p>
  <table>
    <thead><tr><th>Forma</th><th>Tiempo</th></tr></thead>
    <tbody>
      <tr><td><code>filter().uniqBy().take(3)</code></td><td>13,7 ms</td></tr>
      <tr><td><code>takeUniqBy(3, …)</code></td><td><strong>11,3 ms</strong></td></tr>
      <tr><td>un bucle escrito a mano</td><td>10,2 ms</td></tr>
    </tbody>
  </table>
  <p>
    Ambas formas, y ambas barras, están en
    <a href="../DartComparison/recent-errors.html">Mensajes de error recientes,
    deduplicados</a>: la página de comparación que publica tres barras en lugar
    de dos, porque la diferencia entre dos maneras de escribir la misma
    tubería es precisamente lo que quiere mostrar.
  </p>
  <p>
    Así que: recurre a esto cuando la tubería esté en el camino caliente y un
    perfilador diga que estos callbacks son el coste. Antes no. Extensión de
    fxdart — sin equivalente en FxTS, y sin gemelo asíncrono: la ganancia es la
    inserción, que la maquinaria asíncrona eclipsa.
  </p>

  <h2>Demo 1 · Los tres errores distintos más recientes</h2>
  {{playground:0}}

  <h2>Demo 2 · null salta, count es un techo</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: los primeros tres usuarios distintos que llegaron a una página.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="uniqBy.html"><code>uniqBy</code></a> — la deduplicación perezosa que absorbe ·
    <a href="take.html"><code>take</code></a> — el truncado perezoso que absorbe ·
    <a href="uniqStrict.html"><code>uniqStrict</code></a> — el otro miembro estricto de la familia ·
    <a href="performance.html">Rendimiento</a> — de dónde sale el suelo de los callbacks
  </div>
