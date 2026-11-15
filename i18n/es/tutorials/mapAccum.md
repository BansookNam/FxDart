---
slug: mapAccum
title: mapAccum — FxDart 101
description: Tutorial de mapAccum en FxDart: una acumulación progresiva que emite un valor por cada entrada — scan sin la semilla en la salida — con un playground en vivo.
heading: <code>fxMapAccum</code>
section: 3
crumb: mapAccum
prev: scan.html
prevLabel: scan
next: peek.html
nextLabel: peek
---
  <p class="hero-sub">Una acumulación progresiva, un valor de salida por cada valor de entrada: <code>scan</code> sin la semilla.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="scan.html">scan</a></code> emite primero su semilla, así
    que <code>n</code> valores de entrada dan <code>n + 1</code> de salida.
    Eso es correcto cuando el estado inicial forma parte de la respuesta —el
    saldo de apertura de un libro de cuentas— e incorrecto cuando solo es el
    estado en el que se pliega el primer elemento, y por eso tantas llamadas
    a <code>scan</code> acaban con un <code>.drop(1)</code> al final.
    <code>fxMapAccum(f, seed, xs)</code> es esa forma como un único
    operador: pliega cada valor sobre <code>seed</code> con <code>f</code> y
    emite cada acumulación intermedia, pero nunca la semilla misma.
    <code>n</code> de entrada, <code>n</code> de salida: una entrada vacía no
    emite nada en absoluto.
  </p>
  <p>
    El orden de los argumentos coincide con el de <code>fxScan</code> a
    propósito, así que pasar de uno a otro es cambiar una palabra. Es
    perezoso, <code>f</code> se ejecuta exactamente una vez por cada elemento
    del que se tira, en orden, y el acumulador pertenece a la iteración:
    iterar dos veces empieza desde <code>seed</code> ambas veces. El tipo
    del acumulador <code>B</code> no tiene por qué coincidir con el del
    elemento: pliega cadenas en una ruta, números en un registro.
  </p>
  <p>
    <code>fxMapAccumAsync</code> admite que tanto <code>f</code> como
    <code>seed</code> sean un <code>Future</code>. El pliegue se serializa
    —cada paso necesita el anterior—, pero una etapa aguas arriba puede
    seguir ejecutándose con
    <code><a href="concurrent.html">concurrent(n)</a></code>, como en la
    Demo 2. En la cadena es <code>fx(xs).mapAccum(f, seed)</code>. Extensión
    de fxdart (no forma parte de FxTS): el <code>Iterator::scan</code> de
    Rust, el <code>mapAccumL</code> de Haskell y el <code>scan</code> de
    RxDart emiten los mismos <code>n</code> valores.
  </p>

  <h2>Demo 1 · scan, menos la semilla</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia aguas arriba</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: elimina el <code>drop(1)</code> del final.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="scan.html"><code>scan</code></a> — el mismo pliegue, con la semilla ·
    <a href="reduce.html"><code>reduce</code>/<code>fold</code></a> — solo el valor final ·
    <a href="drop.html"><code>drop</code></a> — lo que <code>mapAccum</code> te ahorra ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo aguas arriba
  </div>
