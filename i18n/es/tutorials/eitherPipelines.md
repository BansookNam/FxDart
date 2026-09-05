---
slug: eitherPipelines
title: Either × pipelines — FxDart 101
description: Tutorial de FxDart sobre errores tipados fusionados con pipelines: rights, lefts, separated, sequence fail-fast y mapOrAccumulate fail-slow con concurrencia.
heading: <code>Either</code> × pipelines
section: 13
crumb: Either × pipelines
prev: accumulate.html
prevLabel: accumulation
next: namingOfTypedErrors.html
nextLabel: the naming rationale
---
  <p class="hero-sub">
    Errores tipados fusionados con los pipelines perezosos y conscientes de la
    concurrencia de FxDart — la pieza que no tienen ni Arrow ni ninguna
    librería FP de Dart.
  </p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Una cadena de valores <code>Either</code> gana <em>terminales</em> que
    entienden de Either: <code>rights()</code> y <code>lefts()</code> se
    quedan con uno de los dos lados, <code>separated()</code> parte los dos a
    la vez (con la misma forma de record que <code>partition</code>) y
    <code>sequence()</code> es todo o nada — recoge todos los aciertos en una
    sola lista y falla <em>rápido</em> en el primer <code>Left</code>. Como el
    pipeline es perezoso, el fail-fast es literal: <code>sequence()</code>
    deja de <em>tirar</em> de valores en el primer fallo, así que los
    elementos posteriores nunca llegan a computarse.
  </p>
  <p>
    Su gemelo fail-slow es <code>mapOrAccumulate(transform)</code> sobre
    cualquier cadena <code>fx()</code>/asíncrona: valida todos los elementos y
    conserva todos los fallos. En cadenas asíncronas acepta
    <code>concurrency:&nbsp;n</code> y viaja por el mismo canal de retorno
    <code>concurrent(n)</code> que el resto de FxDart — n elementos en vuelo,
    resultados en orden, y cada elemento se ejecuta en su propio ámbito, así
    que un fallo en uno jamás puede filtrarse a otro.
  </p>
  <p>
    Todos ellos son <em>ansiosos</em> por diseño, lo que además los convierte
    en la vía de escape autorizada del peligro pereza × raise: nunca
    devuelvas un pipeline perezoso desde un bloque raise — devuelve en su
    lugar uno de estos resultados.
  </p>

  <h2>Demo 1 · rights, lefts &amp; separated</h2>
  {{playground:0}}

  <h2>Demo 2 · sequence — fail-fast, literalmente</h2>
  {{playground:1}}

  <h2>Demo 3 · validación fail-slow concurrente</h2>
  {{playground:2}}

  <h2>Demo 4 · flattenOrAccumulate y los extractores async</h2>
  <p>
    Cuando ya <em>tienes</em> los <code>Either</code>s, el terminal
    fail-slow se escribía
    <code>mapOrAccumulate((r,&nbsp;v)&nbsp;=&gt;&nbsp;r.bind(v))</code> — un
    bind identidad. <code>flattenOrAccumulate()</code> (el nombre de Arrow)
    es ese terminal directamente: cada éxito, o <em>cada</em> fallo como un
    <code>Nel</code>. Completa el trío — <code>separated()</code> conserva
    ambos lados, <code>sequence()</code> falla rápido,
    <code>flattenOrAccumulate()</code> falla lento. Y la cadena async ya
    lleva la familia completa de extractores (<code>rights</code> /
    <code>lefts</code> / <code>separated</code> / <code>sequence</code> /
    <code>flattenOrAccumulate</code>), así que una validación async alimenta
    una insignia de conteos en un solo terminal.
  </p>
  {{playground:4}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: suma lo que sí se parseó e informa de lo que no.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="accumulate.html">acumulación</a> — el vocabulario fail-slow a nivel de ámbito ·
    <a href="concurrent.html"><code>concurrent</code></a> — el canal de retorno por el que viaja la variante asíncrona ·
    <a href="partition.html"><code>partition</code></a> — el primo de <code>separated()</code> basado en predicados ·
    <a href="separated.html"><code>rights</code> / <code>separated</code></a> — las mismas extracciones en una cadena de eventos ·
    <a href="typedErrors.html">errores tipados — guía completa</a>
  </div>
