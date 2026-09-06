---
slug: fxPipe
title: fxPipe — FxDart 101
description: Tutorial de fxPipe en FxDart: composición tipada de izquierda a derecha — fxPipe3 o fxPipe(parse).then(normalise).then(score), con playground en vivo.
heading: <code>fxPipe</code>
section: 10
crumb: fxPipe
prev: juxt.html
prevLabel: juxt
next: memoize.html
nextLabel: memoize
---
  <p class="hero-sub">Composición tipada de izquierda a derecha. El último <code>.then</code> <em>es</em> la función — no hay <code>.build()</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>pipe</code> pasa un valor por una lista de funciones, pero la
    lista es <code>dynamic</code>. <code>fxPipe</code> es la forma tipada
    que devuelve una función:
  </p>
  <pre><code>final f = fxPipe3(parse, normalise, score);
f(line);
fx(lines).map(f);</code></pre>
  <p>
    Cada <code>.then</code> devuelve la cadena hasta ahora, así que no
    hay nada que "terminar." Llámalo, o pásalo a <code>map</code> /
    <code><a href="parallel.html">parallel</a></code>.
    <code>fxPipe(parse)</code> es simplemente <code>parse</code> — el
    nombre marca el inicio. <code>parse.then(normalise)</code> también
    vale.
  </p>
  <p>
    Dos llamadas a <code>.parallel</code> copian cada resultado de
    vuelta a este isolate y otra vez hacia fuera. Un worker compuesto
    paga el hop una vez:
  </p>
  <pre><code>await fx(lines)
    .parallel(4, fxPipe3(parse, normalise, score), chunked: true)
    .toList();</code></pre>
  <p>
    Las etapas tienen que ser enviables cuando el resultado es un
    worker de <code>parallel</code>. <code>juxt</code> es la otra
    dirección: varias funciones, una entrada, una lista de resultados.
  </p>
  <p>
    <code>fxPipe2</code>..<code>fxPipe5</code> fusionan las mismas etapas
    en un solo closure, así un <code>map</code> o worker
    <code>parallel</code> caliente no paga una llamada anidada por
    cada <code>.then</code>. La aridad para en 5, como
    <code>zipOrAccumulate2..5</code>. Más allá, sigue encadenando
    <code>.then</code> o escribe la función fusionada tú.
  </p>
  <p>
    <code>parallel</code> es solo VM, así que los playgrounds de abajo
    corren la misma función compuesta a través de <code>map</code>.
  </p>

  <h2>Demo 1 · parse, normalise, score</h2>
  <p>
    Tres etapas, una función. En la VM se lo pasarías a
    <code>parallel</code>; aquí corre en el playground.
  </p>
  {{playground:0}}

  <h2>Demo 2 · Los mismos números que tres maps</h2>
  <p>
    <code>fxPipe</code> es composición, no un operador nuevo. Tres
    <code>map</code>s y una función compuesta imprimen la misma lista.
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: compón <code>parse</code> → <code>normalise</code> →
    <code>score</code> y quédate solo con las filas que puntúan al
    menos 4.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pipe.html"><code>pipe</code></a> — la misma idea, sin tipos, sobre un valor ·
    <a href="juxt.html"><code>juxt</code></a> — varias funciones, una entrada, una lista de resultados ·
    <a href="map.html"><code>map</code></a> — la misma composición en este isolate ·
    <a href="parallel.html"><code>parallel</code></a> — donde componer workers ahorra un hop
  </div>
