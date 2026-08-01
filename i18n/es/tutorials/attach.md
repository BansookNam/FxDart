---
slug: attach
title: attach — FxDart 101
description: Tutorial de attach en FxDart — empareja cada valor con lo que derivas de él, la entrada se queda junto a su resultado. Con playground en vivo.
heading: <code>attach</code>
section: 3
crumb: attach
prev: pluck.html
prevLabel: pluck
next: filter.html
nextLabel: filter
---
  <p class="hero-sub">Empareja cada valor con lo que derivas de él — la entrada se queda junto a su resultado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="map.html">map</a></code> reemplaza cada valor por su
    resultado — y en cuanto necesitas la <em>entrada</em> otra vez aguas
    abajo (para un respaldo, para etiquetar, para loguear), te encuentras
    construyendo registros a mano:
    <code>.map((x)&nbsp;async&nbsp;=&gt;&nbsp;(x,&nbsp;await&nbsp;f(x)))</code>.
    <code>attach(f)</code> es ese idioma como operador: produce pares
    <code>(valor, f(valor))</code>, perezosamente.
  </p>
  <p>
    Donde se gana el sueldo es en las cadenas async. Busca un precio por
    artículo y el par mantiene el artículo junto al precio (quizá ausente),
    de modo que el respaldo
    <code>r.$2&nbsp;??&nbsp;r.$1.listPrice</code> y la etiqueta «¿de qué
    SKU era esto?» siguen al alcance. La forma async está construida sobre
    <code>mapAsync</code>, así que es segura en paralelo — pon
    <code><a href="concurrent.html">concurrent(n)</a></code> después y
    corren <em>n</em> búsquedas a la vez.
  </p>
  <p>
    Adición nativa de Dart (sin contraparte en FxTS). Cuando solo necesitas
    el valor derivado, sigue con <code>map</code>; cuando lo necesitas
    indexado por la entrada como tabla de búsqueda, eso es
    <code><a href="indexBy.html">indexBy</a></code>.
  </p>

  <h2>Demo 1 · La entrada sobrevive al map</h2>
  {{playground:0}}

  <h2>Demo 2 · Búsquedas async con respaldo</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: mantén cada consulta junto a sus resultados de búsqueda.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="map.html"><code>map</code></a> — cuando la entrada puede irse ·
    <a href="zip.html"><code>zip</code></a> — emparejar dos secuencias <em>separadas</em> ·
    <a href="concurrent.html"><code>concurrent</code></a> — acota el fan-out async después de attach
  </div>
