---
slug: keys
title: keys — FxDart 101
description: Tutorial de keys en FxDart: un Iterable perezoso con las claves de un Map, listo para alimentar una cadena.
heading: <code>fxKeys</code>
section: 2
crumb: keys
prev: entries.html
prevLabel: entries
next: values.html
nextLabel: values
---
  <p class="hero-sub">Las claves de un Map, como un Iterable perezoso normal — listo para envolver con fx() y encadenar.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>fxKeys(map)</code> es un envoltorio fino, al estilo FxTS, sobre el
    propio <code>map.keys</code> de Dart — existe sobre todo para que el
    vocabulario de funciones de objeto (<code>fxEntries</code>,
    <code>fxKeys</code>, <code>fxValues</code>) se lea de forma coherente y encaje
    directamente en <code>fx()</code>. El <code>Map.keys</code> de Dart ya es
    una vista perezosa, así que <code>fxKeys</code> no añade ningún búfer
    extra: simplemente te entrega ese mismo
    <code>Iterable&lt;K&gt;</code> perezoso.
  </p>
  <p>
    Recurre a él cuando quieras filtrar, transformar o recolectar el conjunto
    de claves de un Map con el resto del vocabulario de la cadena, en lugar de
    llamar a <code>.where()</code>/<code>.toList()</code> sobre
    <code>map.keys</code> directamente — son equivalentes, pero
    <code>fx(fxKeys(map))</code> se lee con naturalidad junto a
    <code>fx(fxValues(map))</code> y
    <code>fx(fxEntries(map))</code>.
  </p>
  <p>
    Si necesitas las claves <em>y</em> los valores a la vez, usa
    <code>fxEntries</code>: obtener <code>fxKeys</code> y
    <code>fxValues</code> por separado no garantiza que se correspondan si el
    map subyacente se mutara entre ambas llamadas.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Filtrar un Map por sus claves</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>fxKeys</code> y <code>sort</code> para obtener una
    lista de nombres de artículos ordenada alfabéticamente.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="entries.html"><code>fxEntries</code></a> — claves y valores emparejados ·
    <a href="values.html"><code>fxValues</code></a> — los valores de un Map ·
    <a href="pick.html"><code>fxPick</code></a> — construir un Map nuevo a partir de un subconjunto de claves ·
    <a href="fx.html"><code>fx</code></a> — la cadena a la que alimentan los resultados de keys
  </div>
