---
slug: flatMap
title: flatMap — FxDart 101
description: Tutorial de flatMap en FxDart: transforma cada elemento en un iterable y aplana un nivel, con un playground en vivo.
heading: <code>flatMap</code>
section: 3
crumb: flatMap
prev: mapEffect.html
prevLabel: mapEffect
next: flat.html
nextLabel: flat
---
  <p class="hero-sub">Transforma cada elemento en un iterable y luego aplana los resultados un nivel — el mismo contrato que <code>Iterable.expand</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>flatMap</code> es <code>map</code> seguido de un nivel de
    aplanado: cada elemento se convierte en una <em>colección</em> de
    resultados, y esas colecciones se empalman en una única secuencia
    perezosa y plana. Es la herramienta para «una entrada, muchas salidas»:
    partir una frase en palabras, expandir un usuario en sus pedidos, convertir
    un rango en pares.
  </p>
  <p>
    <strong>Desviación respecto a FxTS:</strong> en FxTS, el callback puede devolver cualquier mezcla
    de valores sueltos e iterables y <code>flatMap</code> deduce qué
    aplanar mediante la magia de tipos de <code>DeepFlat</code>. Dart no tiene equivalente
    de ese tipo condicional, así que el port a Dart exige que <code>f</code>
    devuelva <em>siempre</em> un <code>Iterable&lt;B&gt;</code> — exactamente como
    <a href="https://api.dart.dev/stable/dart-core/Iterable/expand.html"><code>Iterable.expand</code></a>.
    Devuelve una lista de un solo elemento (<code>[x]</code>) para emitir exactamente un
    valor por entrada, o una lista vacía para no emitir ninguno.
  </p>
  <p>
    En el lado asíncrono, la máquina de estados interna de <code>flatMapAsync</code>
    tiene que recordar «qué subiterable estoy vaciando ahora mismo» entre extracciones,
    así que consume su fuente <em>en serie</em>: envolverlo en
    <code>.concurrent(n)</code> solo acelera la extracción de elementos
    ya disponibles, no un <code>await</code> que ocurra dentro del propio
    callback. Si necesitas trabajo asíncrono concurrente por elemento, hazlo en
    una etapa <code>.map(...).concurrent(n)</code> previa y después
    <code>.flatMap((list) =&gt; list)</code> para aplanar las
    listas ya resueltas — mira la Demo 2.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>El callback debe devolver un <code>Iterable</code>: aquí, una lista de
    2 elementos y una llamada a <code>String.split</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, la forma correcta de obtener concurrencia</h2>
  <p>
    Pon el <code>await</code> lento en una etapa <code>.map(...).concurrent(n)</code>
    y deja que <code>flatMap</code> aplane los resultados de forma síncrona:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>flatMap</code> para partir cada frase en palabras,
    produciendo una única lista plana de palabras.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="map.html"><code>map</code></a> — transformar sin aplanar ·
    <a href="flat.html"><code>flat</code></a> — aplanar un iterable ya anidado ·
    <a href="mapEffect.html"><code>mapEffect</code></a> — map para efectos secundarios ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
