---
slug: first-over-budget-rx
title: Primera transacción por encima del presupuesto — RxDart vs FxDart
description: Encontrar la primera transacción por encima de 100 y detenerse — el firstWhere de Rx cancela la suscripción, el find de fxdart deja de tirar; ambos examinan solo 4 de 8.
heading: Primera transacción por encima del presupuesto
order: 1
tier: 1
functions: fx, find
domain: transactions
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Recorre el feed de tarjeta de esta semana en orden de llegada e
    informa de la <strong>primera</strong> transacción por encima del
    presupuesto de 100 — y deja de buscar. Imprime también cuántas
    transacciones se examinaron realmente, para demostrar que la búsqueda
    cortocircuitó. Los datos están en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Aquí ambos lados son genuinamente perezosos, cada uno en su propio
    dialecto. El <code>firstWhere</code> de RxDart resuelve su future en
    la primera coincidencia y <strong>cancela la suscripción</strong> —
    las cuatro transacciones restantes nunca se entregan. El
    <code>find</code> de FxDart simplemente <strong>deja de
    tirar</strong> — las cuatro transacciones restantes nunca se
    demandan. Cancelación y demanda son las palabras de cada modelo para
    la misma economía, y la línea «Examined 4 of 8» sale idéntica en
    ambos lados.
  </p>
  <p>
    La diferencia instructiva es <em>dónde vive el contador</em>. Un
    stream tiene un «entre»: <code>doOnData</code> pincha la tubería entre
    operadores, así que el predicado rx se mantiene puro mientras el tap
    observa el tráfico. Una cadena pull no tiene «entre» — el momento de
    la demanda es la propia llamada al predicado, así que el lado FxDart
    cuenta dentro de él. Ninguna de las dos formas es mejor; son los
    idiomas de observación nativos de push y pull. Veredicto: empate — un
    operador cada uno, y ambos se detienen exactamente en el momento
    justo.
  </p>

  <h3>Por qué la diferencia del benchmark es tan grande</h3>
  <p>
    Las barras de abajo no miden la pereza. A la escala del benchmark, la
    primera transacción por encima del presupuesto está en el elemento
    900 001 de un millón, y <strong>ambos lados examinan exactamente
    900 001</strong> — los checksums lo demuestran. Lo que miden las
    barras es el precio de que un elemento atraviese cada modelo: unos
    <strong>1 ns</strong> del lado pull, unos <strong>88 ns</strong> del
    lado push.
  </p>
  <p>
    Eso no es un defecto de RxDart, ni una forma de escribirlo que se
    arregle eligiendo mejor los operadores. Medimos las alternativas sobre
    el mismo conjunto de datos — 900 001 elementos, resultados idénticos:
  </p>
  <ul>
    <li><code>where().first</code> en lugar de <code>firstWhere</code>:
      50 ns (la combinación de operadores más rápida que encontramos)</li>
    <li>contar dentro del predicado en lugar de un tap
      <code>doOnData</code>, lo que elimina una capa de transformación:
      62 ns</li>
    <li><code>await for</code> con <code>break</code>, sin operadores:
      227 ns — el más lento, no el más rápido</li>
    <li>un <code>StreamController</code> síncrono movido a mano, que ya no
      es Rx idiomático pero es el suelo del modelo push: 20 ns</li>
  </ul>
  <p>
    Incluso ese suelo es 20× la cadena pull. La razón es estructural. Un
    <code>Stream</code> es un <em>mecanismo de entrega</em>: cada valor se
    entrega a una suscripción, a través de todas las capas de
    transformación que tenga la cadena, con la disciplina del bucle de
    eventos que hace seguro compartir, pausar, cancelar y componer un
    stream a través de fronteras asíncronas. El <code>find</code> de
    FxDart sobre una <code>List</code> compila a un bucle indexado que
    llama a un closure por elemento y retorna — no hay entrega, ni
    suscripción, ni planificación, porque aquí nada es realmente
    asíncrono.
  </p>
  <h3>¿No está amañado por dónde se sitúa el disparador?</h3>
  <p>
    Pregunta justa, y lo único de este caso que <em>sí</em> es una decisión de
    criterio. Como la búsqueda se cortocircuita, es el conjunto de datos el que
    decide cuánto trabajo se hace: el benchmark coloca la primera transacción
    por encima del presupuesto al 90% del recorrido, así que una ejecución de
    un millón examina 900.001. Muévela y ambos lados trabajan proporcionalmente
    menos. Si la diferencia fuese un artefacto de esa elección, adelantar el
    disparador la cerraría.
  </p>
  <p>
    No la cierra. Medido seguido en una máquina ociosa, cinco rondas cada uno,
    con el conjunto del 90% ejecutado dos veces para mostrar el ruido:
  </p>
  <table>
    <thead>
      <tr>
        <th>Escala</th><th>Disparador</th><th>Examinados</th>
        <th>RxDart</th><th>FxDart</th><th>Factor</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>100</td><td>90%</td><td>91</td>
        <td>10 µs</td><td>286 ns</td><td>35×</td></tr>
      <tr><td>100</td><td>90% (repetición)</td><td>91</td>
        <td>11 µs</td><td>280 ns</td><td>39×</td></tr>
      <tr><td>100</td><td>50%</td><td>51</td>
        <td>7,5 µs</td><td>256 ns</td><td>29×</td></tr>
      <tr><td>1.000.000</td><td>90%</td><td>900.001</td>
        <td>79,1 ms</td><td>861 µs</td><td>92×</td></tr>
      <tr><td>1.000.000</td><td>90% (repetición)</td><td>900.001</td>
        <td>78,9 ms</td><td>901 µs</td><td>88×</td></tr>
      <tr><td>1.000.000</td><td>50%</td><td>500.001</td>
        <td>44,2 ms</td><td>374 µs</td><td>118×</td></tr>
    </tbody>
  </table>
  <p>
    Reducir el trabajo a la mitad reduce a la mitad ambos lados — y el factor
    <em>se ensancha</em>, de 88× a 118×. Divide las filas del millón entre los
    elementos examinados y la razón queda clara: RxDart cuesta <strong>87,7,
    87,9 y 88,4 ns</strong> por elemento en las tres ejecuciones, plano
    independientemente de dónde esté el disparador, mientras que FxDart cuesta
    <strong>1,00, 0,96 y 0,75 ns</strong> — el recorrido más corto sale incluso
    algo más barato por elemento. Adelantar el disparador, si acaso, favorece a
    FxDart. Las filas de 100 elementos las domina el coste fijo de arranque y
    no el coste por elemento, por eso sus factores son menores y más ruidosos;
    y por eso mismo existe la escala grande.
  </p>
  <p>
    Así que el 90% no está ahí para inflar nada — está ahí para que la escala
    grande mida el <em>tirar de los datos</em> y no el arranque, y es la
    posición menos favorable a FxDart de las que probamos. Lo que la posición
    no puede cambiar es el precio por elemento, y en eso consiste toda la
    diferencia.
  </p>

  <p>
    Así que la lectura honesta de estas barras es estrecha: <em>cuando la
    fuente ya está en memoria y la pregunta es síncrona, hacerla pasar por
    un stream es puro sobrecoste.</em> Convierte la fuente en algo
    genuinamente asíncrono — un socket, un websocket, una API paginada — y
    ese coste por elemento desaparece bajo la E/S que el stream fue
    diseñado para gestionar, que es justo el terreno que cubre la Parte 4.
    El veredicto del código sigue siendo empate: ambos escriben el mismo
    cortocircuito con un operador, y ambos se detienen en el momento
    justo.
  </p>
