---
slug: not
title: not — FxDart 101
description: Tutorial de not en FxDart: la negación booleana como valor de función que puedes pasar de un lado a otro, con un playground en vivo.
heading: <code>not</code>
section: 10
crumb: not
prev: negate.html
prevLabel: negate
next: when.html
nextLabel: when
---
  <p class="hero-sub">La negación booleana como una función que puedes pasar de un lado a otro.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>not</code> hace exactamente lo mismo que <code>!a</code> — solo que lo hace
    como función de primera clase, así que puedes pasarlo donde se espera un
    <code>bool Function(bool)</code> en lugar de escribir tú mismo
    <code>(b) =&gt; !b</code>. El <code>not</code> de FxTS opera sobre valores
    "truthy" de JavaScript de cualquier tipo; Dart no tiene valores truthy implícitos,
    así que el port a Dart solo acepta un <code>bool</code> real.
  </p>
  <p>
    Como su firma es <code>bool -&gt; bool</code>, <code>not</code> sirve
    además como predicado en sí mismo siempre que el tipo de los elementos ya sea
    <code>bool</code> — mira <code>some</code>/<code>every</code> en la Demo 2.
    Para negar un predicado cualquiera sobre otro tipo, usa
    <a href="negate.html"><code>negate</code></a>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Como predicado sobre booleanos</h2>
  <p>
    <code>not</code> es en sí mismo un <code>bool Function(bool)</code>, así que
    encaja directamente en <code>some</code>/<code>every</code> sin envolturas:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>not</code> para construir la lista de flags "aún pendiente"
    a partir de una lista de flags "hecho".</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="negate.html"><code>negate</code></a> — niega una función predicado entera, no solo un bool ·
    <a href="some.html"><code>some</code></a> / <a href="every.html"><code>every</code></a> — usados arriba junto a not ·
    <a href="when.html"><code>when</code></a> — transformación condicional ·
    <a href="unless.html"><code>unless</code></a> — el hermano de when con la condición invertida
  </div>
