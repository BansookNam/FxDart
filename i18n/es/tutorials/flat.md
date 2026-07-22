---
slug: flat
title: flat — FxDart 101
description: Tutorial de flat en FxDart: aplana iterables anidados hasta la profundidad que indiques, con un playground en vivo.
heading: <code>flattened</code>
section: 3
crumb: flattened
prev: flatMap.html
prevLabel: flatMap
next: scan.html
nextLabel: scan
---
  <p class="hero-sub">Aplana iterables anidados hasta la profundidad indicada — las cadenas se dejan intactas.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>flat</code> recorre una estructura anidada de iterables e inserta
    los elementos interiores en la secuencia exterior, hasta
    <code>depth</code> niveles de profundidad (por defecto <code>1</code>).
    Todo lo que sea un <code>Iterable</code> cuenta como "aplanable"
    <em>excepto</em> <code>String</code> — así que
    <code>flat(['ab', ['cd']])</code> conserva <code>'ab'</code> entero en
    vez de descomponerlo en caracteres.
  </p>
  <p>
    <strong>Por qué <code>Iterable&lt;dynamic&gt;</code>, y por qué no pasa nada:</strong>
    el <code>flat</code> de TypeScript tiene un tipo condicional
    <code>DeepFlat</code> capaz de describir "el tipo del elemento tras
    aplanar N niveles". El sistema de tipos de Dart no tiene un mecanismo
    equivalente — la forma del anidamiento de la entrada no se conoce hasta
    tiempo de ejecución, así que no hay manera sólida de calcular un tipo de
    elemento estático. En lugar de mentir con un genérico que no se sostiene,
    el port a Dart es honesto y devuelve <code>Iterable&lt;dynamic&gt;</code>.
    Si conoces la forma de lo que estás aplanando y quieres un resultado
    tipado, tira de <a href="flatMap.html"><code>flatMap</code></a>
    en su lugar: <code>flatMap((row) =&gt; row, matrix)</code> te da un
    aplanado tipado para datos de exactamente un nivel y forma uniforme.
  </p>
  <p>
    Igual que <code>flat</code> en FxTS, <code>flatAsync</code> solo baja
    por el anidamiento que ya sea, de forma <em>síncrona</em>, un
    <code>Iterable</code> en el momento en que llega — no espera a un <code>Future</code>
    escondido dentro de una colección anidada. Combínalo con una etapa previa
    <code>.map(...).concurrent(n)</code> para traer las listas anidadas en
    paralelo, y deja que <code>.flat()</code> junte después los resultados ya
    resueltos.
  </p>

  <h2>Demo 1 · Fundamentos &amp; profundidad</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  <p>
    Trae los resultados (ya anidados) de forma concurrente y luego aplana las
    listas resueltas:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>flat()</code> para aplanar <code>scoreGroups</code>
    un nivel.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="flatMap.html"><code>flatMap</code></a> — map + aplanado tipado en un solo paso ·
    <a href="map.html"><code>map</code></a> — transforma sin aplanar ·
    <a href="scan.html"><code>scan</code></a> — acumulación progresiva ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
