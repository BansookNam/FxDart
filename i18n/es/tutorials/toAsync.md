---
slug: toAsync
title: toAsync — FxDart 101
description: Tutorial de toAsync en FxDart: eleva un Iterable normal a un FxAsyncIterable y entiende el modelo asíncrono basado en pull, con playground en vivo.
heading: <code>toAsync</code>
section: 11
crumb: toAsync
next: asyncVariants.html
nextLabel: async variants
---
  <p class="hero-sub">Eleva un Iterable normal —de valores o de Futures— a un FxAsyncIterable, la puerta de entrada al pipeline asíncrono de FxDart.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Todo pipeline asíncrono de FxDart empieza con <code>toAsync</code>. Toma
    un <code>Iterable&lt;FutureOr&lt;T&gt;&gt;</code> normal —una lista de
    valores simples, una lista de Futures o una mezcla— y lo envuelve en un
    <code>FxAsyncIterable</code>, el tipo que entienden todos los operadores
    <code>*Async</code> y la cadena <code>FxAsync</code>. Cada vez que un
    elemento resulta ser un <code>Future</code>, se espera automáticamente
    conforme se extrae.
  </p>
  <p>
    <code>FxAsyncIterable</code> está <strong>basado en pull</strong>: nada se
    ejecuta hasta que un terminal (<code>toArrayAsync</code>,
    <code>eachAsync</code>, el <code>.toArray()</code> de la cadena
    <code>FxAsync</code>, …) llama a <code>next()</code> sobre él, un paso
    cada vez — exactamente igual que un <code>Iterable</code> normal, solo que
    asíncrono. Es un alejamiento deliberado del <code>Stream</code> de
    Dart, que está basado en <em>push</em>: en cuanto un stream empieza a
    emitir, es él quien decide el ritmo, y un consumidor aguas abajo no tiene
    forma de decirle «evalúa 3 de estos a la vez». El protocolo
    <code>next([Concurrent? concurrent])</code> de FxDart añade justo ese
    canal de retorno: un operador aguas abajo como <code>concurrent(n)</code>
    puede pasar un marcador <em>aguas arriba</em> con cada pull, pidiéndole a
    la fuente que ejecute <code>n</code> elementos en paralelo. Los Streams no
    ofrecen ningún punto de enganche equivalente, y esa es justo la razón por
    la que FxDart define su propio iterable asíncrono en vez de construir sobre
    <code>Stream</code>.
  </p>
  <p>
    Usa el <code>toAsync(iterable)</code> de nivel superior para un
    <code>Iterable&lt;FutureOr&lt;T&gt;&gt;</code> en crudo, o el método de
    cadena <code>fx(iterable).toAsync()</code> para pasar una cadena
    <code>Fx</code> existente a su equivalente <code>FxAsync</code>. Ambos son
    perezosos: construir el pipeline no hace nada hasta que algo tira de él.
  </p>

  <h2>Demo 1 · Valores, Futures y la forma encadenada</h2>
  <p><code>toAsync</code> acepta valores simples, Futures o una mezcla de
    ambos — y la forma encadenada hace lo mismo a partir de un <code>Fx</code>
    existente:</p>
  {{playground:0}}

  <h2>Demo 2 · Por qué importa el modelo basado en pull</h2>
  <p>
    En Dart, un <code>Future</code> empieza a ejecutarse en el instante en que
    se crea, no cuando se espera. Así que tres Futures construidos de forma
    ansiosa en un literal de lista ya se están ejecutando en paralelo antes de que
    <code>toAsync</code> los toque siquiera. Compáralo con
    <code>mapAsync</code> (o el <code>.map</code> de la cadena), que crea un
    Future nuevo por elemento solo cuando se <em>tira</em> de él — de forma
    perezosa, uno a uno, salvo que añadas <code>concurrent(n)</code>:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: filtra la lista de abajo para que solo las notas aprobadas
    (&gt;= 60) lleguen al resultado.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="asyncVariants.html">convención de nombres <code>*Async</code></a> — mapAsync, filterAsync, … ·
    <a href="streams.html">puentes con Stream</a> — fromStream, fxStream, toStream ·
    <a href="concurrent.html"><code>concurrent</code></a> — el canal de retorno en acción ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — para construir demos asíncronas
  </div>
