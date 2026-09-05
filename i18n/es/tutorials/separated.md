---
slug: separated
title: rights, lefts &amp; separated — FxDart 101
description: Tutorial de separated en FxDart: desenrolla éxitos, desenrolla fallos, o divide una cadena de eventos Either en ambas mitades — con playground en vivo.
heading: <code>rights</code>, <code>lefts</code> &amp; <code>separated</code>
section: 14
crumb: separated
prev: mapEither.html
prevLabel: mapEither
next: share.html
nextLabel: share
---
  <p class="hero-sub">Operadores conscientes de Either sobre una cadena de eventos de valores <code>Either</code> — desenrolla un lado, o divide ambos a la vez.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Una vez que una cadena es <code>FxEvents&lt;Either&lt;L, R&gt;&gt;</code>
    — desde <code><a href="attempt.html">attempt</a></code> o
    <code><a href="mapEither.html">mapEither</a></code> —
    estos tres operadores son las contrapartes del lado push de
    <code><a href="eitherPipelines.html">FxEitherOps</a></code>.
    <code>rights()</code> conserva solo los éxitos, desenrollados;
    <code>lefts()</code> conserva solo los fallos, desenrollados;
    <code>separated()</code> divide en
    <code>(failures, successes)</code> — la forma <code>Either</code>
    de <code><a href="partition.html">partition</a></code>.
  </p>
  <p>
    Aquí no viven terminales. <code>pull()</code> entrega la cadena a
    <code>FxAsync</code>, donde <code>sequence()</code> y
    <code>flattenOrAccumulate()</code> ya existen. Estos operadores
    se quedan en la capa de eventos para que una UI pueda escuchar
    éxitos y fallos como dos feeds.
  </p>
  <p>
    <code>separated()</code> hereda las reglas de vida de
    <code>partition</code>: el record se devuelve de inmediato,
    escuchar cualquiera de los lados arranca la fuente, cancelar ambos
    la cancela, y un valor que pertenece a un lado al que nadie
    escucha se descarta en vez de almacenarse en búfer.
  </p>
  <p>
    También hereda el fan-out de errores de <code>partition</code>: un
    <em>evento</em> de error no es un <code>Either</code>, así que va a
    cada lado que esté escuchando — un fallo aguas arriba aparece en
    ambas mitades. Llama a <code>attempt</code> aguas arriba cuando un
    fallo deba contarse una sola vez, como un <code>Left</code> en la
    mitad <code>failures</code>.
  </p>

  <h2>Demo 1 · rights y lefts</h2>
  {{playground:0}}

  <h2>Demo 2 · separated divide ambas mitades</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: un evento de error se propaga a ambas mitades;
    <code>attempt</code> aguas arriba lo cuenta una sola vez.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="eitherPipelines.html">Either × pipelines</a> — los gemelos del lado pull, más <code>sequence</code> y <code>flattenOrAccumulate</code> ·
    <a href="partition.html"><code>partition</code></a> — el primo predicado de <code>separated()</code> ·
    <a href="attempt.html"><code>attempt</code></a> — convierte un evento de error para que cuente una sola vez, en la mitad failures
  </div>
