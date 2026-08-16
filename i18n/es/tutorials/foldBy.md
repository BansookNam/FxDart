---
slug: foldBy
title: foldBy — FxDart 101
description: Tutorial de foldBy en FxDart: reduce los valores de cada clave en una sola pasada, sin materializar los grupos, con un playground en vivo.
heading: <code>foldBy</code>
section: 7
crumb: foldBy
prev: countBy.html
prevLabel: countBy
next: countWhere.html
nextLabel: countWhere
---
  <p class="hero-sub">Reduce los valores de cada clave en una sola pasada: el agregado, sin los grupos.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>foldBy</code> es <code><a href="fold.html">fold</a></code> ejecutado
    una vez por clave en lugar de una vez sobre toda la fuente. Cada elemento
    elige su clave y su valor se reduce dentro del acumulador de esa clave, así
    que el resultado es un <code>Map&lt;K, Acc&gt;</code> de respuestas, no de
    elementos.
  </p>
  <p>
    La razón de que exista es lo que <em>no</em> hace.
    <code><a href="groupBy.html">groupBy</a></code> seguido de una reducción por
    grupo tiene que construir antes una <code>List</code> para cada clave:
    asignación proporcional a la <strong>entrada</strong> para una respuesta
    proporcional al <strong>número de claves</strong>. Si lo único que quieres es
    el total por categoría, esas listas se construyen y se tiran.
    <code>foldBy</code> acumula directamente en el mapa de resultado, que es
    exactamente lo que hace el bucle escrito a mano:
  </p>
  <pre><code>// lo que escribirías a mano
for (final t in txns) {
  totals[t.category] = (totals[t.category] ?? 0) + t.amount;
}

// lo mismo, con nombre
foldBy((Tx t) =&gt; t.category, 0.0, (sum, t) =&gt; sum + t.amount, txns);</code></pre>
  <p>
    Sobre un millón de transacciones repartidas en cinco categorías, esa
    diferencia se midió como una bajada de <strong>3,2× a 1,3×</strong> respecto
    del bucle escrito a mano. Varios de los ejemplos de
    <a href="../DartComparison/index.html">Dart vs FxDart</a> se pasaron a él
    justo por eso.
  </p>
  <p>
    Las claves salen en el <strong>orden en que aparecen por primera vez</strong>,
    igual que en <code>groupBy</code>. No es un port de FxTS: la forma viene de
    <code>groupingBy().fold()</code> de Kotlin.
  </p>

  <div class="callout">
    <strong>La semilla es un valor, no una fábrica.</strong> Igual que en
    <code>fold</code>, <code>seed</code> es un único valor que se usa como punto
    de partida para <em>todas</em> las claves. Eso está bien con números y
    cadenas, que reduces hacia valores nuevos. Una semilla <strong>mutable</strong>
    — una lista, un conjunto, un mapa — la compartirían todas las claves y todas
    la mutarían. Si necesitas acumular en una estructura mutable por grupo, usa
    <code><a href="groupBy.html">groupBy</a></code>.
  </div>

  <h2>Demo 1 · Lo básico</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: la demo cuenta <strong>palabras</strong> por letra inicial.
    Cámbiala para que sume las <strong>letras</strong> bajo cada inicial, de modo
    que <code>fig</code> y <code>fx</code> den <code>{f: 5}</code>.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Cuándo no usarlo:</strong> un acumulador que necesita dos valores en
    curso — una media necesita una suma <em>y</em> un recuento — tiene que
    llevarlos en un record, y se asigna un record por elemento. Eso cuesta más
    que la agrupación que evitas; ahí usa <code>groupBy</code>.
  </div>

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — conserva los elementos en lugar de reducirlos ·
    <a href="countBy.html"><code>countBy</code></a> — <code>foldBy</code> con un contador, ya con nombre ·
    <a href="fold.html"><code>fold</code></a> — la misma reducción sobre un solo acumulador ·
    <a href="groupedBy.html"><code>groupedBy</code></a> — agrupación que se queda en la cadena
  </div>
