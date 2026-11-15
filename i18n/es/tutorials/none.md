---
slug: none
title: none — FxDart 101
description: Tutorial de none en FxDart: true cuando ningún elemento coincide — el tercer cuantificador junto a every y some, que cortocircuita en la primera coincidencia, síncrono y asíncrono.
heading: <code>fxNone</code>
section: 8
crumb: none
prev: atLeast.html
prevLabel: atLeast
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">«¿No coincide nada?» — dicho como un universal, y respondido en el primer contraejemplo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>fxNone(f, xs)</code> es <code>true</code> cuando <code>f</code>
    no se cumple para ningún elemento. Siempre podrías escribirlo como
    <code>!fxSome(f, xs)</code>, y la respuesta es la misma — pero eso se lee
    como un existencial negado («no es cierto que alguno…»), y la negación es
    donde viven los errores de cuantificadores: el <code>!</code> se desliza
    al lado equivocado de un <code>&amp;&amp;</code>, o se pierde en una
    refactorización. <code>none</code> dice la regla tal como la enunciarías.
  </p>
  <p>
    Es el tercer cuantificador junto a
    <code><a href="every.html">every</a></code> y
    <code><a href="some.html">any</a></code>, y los tres están ligados:
    <code>none(f)</code> es <code>!any(f)</code>, es
    <code>every((x)&nbsp;=&gt;&nbsp;!f(x))</code>, y es
    <code><a href="atLeast.html">atMost</a>(0, f)</code>. Igual que
    <code>any</code>, <strong>cortocircuita</strong>: la primera coincidencia
    decide la respuesta (<code>false</code>) y el resto nunca se evalúa. Una
    entrada vacía no tiene contraejemplo, así que da <code>true</code>.
  </p>
  <p>
    En la cadena es <code>fx(xs).none(f)</code>;
    <code>fxNoneAsync</code> y <code>fxAsync(…).none(f)</code> aceptan un
    predicado que espera con await y cancelan el upstream en la coincidencia
    decisiva. Añadido nativo de Dart — FxTS solo tiene
    <code>every</code>/<code>some</code>; Kotlin lo escribe
    <code>none</code>. No tiene relación con
    <code>SingletonRaise.none()</code> del constructor
    <a href="nullable.html">nullable</a>, que cortocircuita un ámbito raise;
    ese es un miembro, así que ningún nombre oculta al otro.
  </p>

  <h2>Demo 1 · Sin coincidencias, entrada vacía, parada temprana</h2>
  {{playground:0}}

  <h2>Demo 2 · Tres formas de escribirlo, y asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: quita el <code>!</code> y di la regla directamente.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="some.html"><code>any</code></a> — <code>none</code> es su negación ·
    <a href="every.html"><code>every</code></a> — el cuantificador universal ·
    <a href="atLeast.html"><code>atMost</code></a> — <code>atMost(0, f)</code> es <code>none</code>
  </div>
