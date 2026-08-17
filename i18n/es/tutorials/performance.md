---
slug: performance
title: Escribir pipelines rápidos — FxDart 101
description: Qué formas de FxDart son rápidas y por qué — operadores terminales, el orden del filter, foldBy en lugar de groupBy y cuándo la pereza te cuesta, con un playground en vivo.
heading: Escribir pipelines rápidos
section: 1
crumb: performance
prev: consume.html
prevLabel: consume
next: range.html
nextLabel: range
---
  <p class="hero-sub">La biblioteca puede hacer que una forma sea rápida; lo que no puede es elegir la forma por ti. Estas son las que compensan.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Cada ejemplo de la comparativa
    <a href="../DartComparison/index.html">Dart vs FxDart</a> se mide contra un
    bucle imperativo escrito a mano, y la mayoría se queda a su altura o muy
    cerca. Cuando una cadena es más lenta, casi nunca es el algoritmo — ambos
    lados hacen el mismo trabajo — y casi siempre es una de cuatro cosas: una
    frontera entre etapas pagada por elemento, una asignación por elemento, un
    callback que se ejecuta más veces de las necesarias, o un origen que se
    recorre más de una vez.
  </p>

  <h3>1. Termina en un operador terminal</h3>
  <p>
    Un terminal como <a href="toList.html"><code>toList</code></a> ve la cadena
    entera y puede tomar una ruta que ningún consumidor elemento a elemento
    puede. Sobre un origen <code>List</code>, <code>map(f).toList()</code> y
    <code>filter(p).toList()</code> delegan la copia al relleno masivo del
    propio SDK, que escribe el resultado sin la comprobación de tipo por
    elemento que el código de paquete está obligado a pagar. Tirar de la misma
    cadena a mano con un <code>for</code>-in e ir acumulando renuncia por
    completo a esa ruta.
  </p>

  <h3>2. Filtra antes de mapear</h3>
  <p>
    Las etapas se ejecutan en el orden en que las escribes, y cada elemento que
    sobrevive a un <code>filter</code> paga todas las etapas posteriores. Poner
    la prueba barata primero y la transformación cara después es gratis y a
    menudo la mayor mejora disponible.
  </p>

  <h3>3. Pide la respuesta, no los ingredientes</h3>
  <p>
    <a href="groupBy.html"><code>groupBy</code></a> construye una
    <code>List</code> por cada clave — asignación proporcional a la
    <strong>entrada</strong> — y si lo único que querías era un total por clave,
    esas listas se construyen y se tiran.
    <a href="foldBy.html"><code>foldBy</code></a> acumula directamente en el mapa
    de resultado, y <a href="countBy.html"><code>countBy</code></a> es la versión
    con contador, ya con nombre. Recurre a <code>groupBy</code> cuando de verdad
    quieras los miembros.
  </p>
  <p>
    Estos dos son además el caso raro en que el operador es más rápido que el
    bucle que habrías escrito. La línea obvia,
    <code>counts[k] = (counts[k] ?? 0) + 1</code>, toca la tabla hash
    <strong>dos veces</strong> por elemento — una para leer y otra para volver
    a escribir — y en un trabajo de conteo la tabla es prácticamente todo el
    coste. Ambos operadores cuentan en una celda mutable alojada en la tabla,
    así que esta se escribe una vez por <em>clave distinta</em> en lugar de una
    vez por elemento: ~1,5× al contar un millón de filas, y es la razón por la
    que <a href="../DartComparison/top-log-level.html">Nivel de log más
    frecuente</a> le gana a un bucle a mano en vez de quedarse por detrás.
  </p>

  <h3>4. Una cadena perezosa se reejecuta en cada pasada</h3>
  <p>
    La pereza significa que la cadena es una receta, no un resultado: recórrela
    dos veces y el origen se recorre dos veces. Cuando la respuesta se usa más
    de una vez, materialízala una sola vez — con
    <a href="toList.html"><code>toList</code></a>, o con
    <a href="uniqStrict.html"><code>uniqStrict</code></a> cuando la propia
    deduplicación es lo que conservas.
  </p>

  <h3>Lo que la pereza te sigue dando</h3>
  <p>
    Nada de esto es un argumento contra las cadenas perezosas. Un
    <code>take</code> o un <code>head</code> después de un filtro detienen el
    origen en cuanto tienen suficiente — el trabajo sencillamente no llega a
    ocurrir — y ese es un tipo de ahorro que ninguna pipeline ansiosa puede
    igualar. La pereza cuesta un poco por elemento y puede ahorrarlo todo.
  </p>

  <div class="callout">
    <strong>Los records no son gratis.</strong> Una etapa que produce un record
    — <a href="zip.html"><code>zip</code></a>,
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a>,
    <a href="pairwise.html"><code>pairwise</code></a>, o un <code>map</code> a
    una tupla — asigna uno por elemento, y un record no se puede reutilizar. Si
    la etapa siguiente descarta la mayoría, plantéate si la pipeline puede
    llevar índices o un solo valor;
    <a href="withIndex.html"><code>mapWithIndex</code></a> existe precisamente
    para que <code>zipWithIndex().map(...)</code> no tenga que asignar un par
    por elemento.
  </div>

  <h2>Demo 1 · Terminales y orden del filter</h2>
  {{playground:0}}

  <h2>Demo 2 · foldBy en lugar de groupBy, y el precio de una segunda pasada</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: el fragmento recorre sus lecturas dos veces y construye una
    lista que luego tira. Reescríbelo como una única cadena que termine en un
    solo operador terminal.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="toList.html"><code>toList</code></a> — el terminal del que cuelgan casi todas las rutas rápidas ·
    <a href="foldBy.html"><code>foldBy</code></a> — agregar sin los grupos ·
    <a href="uniqStrict.html"><code>uniqStrict</code></a> — deduplicar una vez, reutilizar muchas ·
    <a href="withIndex.html"><code>mapWithIndex</code></a> — el índice sin el record
  </div>
