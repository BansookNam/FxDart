---
slug: always
title: always — FxDart 101
description: Tutorial de always en FxDart: crea una función que ignora su argumento y siempre devuelve un valor fijo, con un playground en vivo.
heading: <code>fxAlways</code>
section: 10
crumb: always
prev: identity.html
prevLabel: identity
next: tap.html
nextLabel: tap
---
  <p class="hero-sub">Devuelve una función que siempre devuelve el mismo valor fijo, ignorando su argumento.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>fxAlways(a)</code> captura <code>a</code> y te devuelve una
    función que descarta aquello con lo que la llames y devuelve <code>a</code>
    cada vez. El parámetro opcional es el truco que le permite encajar en
    cualquier sitio donde se espere un callback <em>unario</em> — un
    mapeador, un manejador <code>orElse</code>, una rama de reserva — sin que
    tengas que escribir <code>(_) => a</code> a mano cada vez.
  </p>
  <p>
    Es la contraparte constante de <a href="identity.html"><code>fxIdentity</code></a>:
    <code>fxIdentity</code> deja pasar la entrada, <code>fxAlways</code>
    la desecha. Ambas son funciones síncronas simples, sin variante asíncrona
    ni forma encadenada.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Fíjate en el argumento opcional — <code>greet(123)</code> sigue devolviendo
    <code>'hi'</code>, que es justo lo que le permite actuar como callback de <code>map</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Valor por defecto constante en una tabla de despacho</h2>
  <p>
    <code>fxAlways</code> encaja de forma natural como <code>orElse</code> en
    <a href="cases.html"><code>fxCases</code></a> — un valor por defecto fijo que
    no necesita mirar el valor que no coincidió:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>fxAlways</code> para reemplazar cada nota de esta lista
    por la cadena <code>'graded'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="identity.html"><code>fxIdentity</code></a> — deja pasar el argumento en lugar de descartarlo ·
    <a href="cases.html"><code>fxCases</code></a> — tabla de despacho que suele acompañarse de always como orElse ·
    <a href="when.html"><code>fxWhen</code></a> — transformación condicional, entra un valor y sale un valor ·
    <a href="memoize.html"><code>fxMemoize</code></a> — cachea un valor calculado en vez de uno constante
  </div>
