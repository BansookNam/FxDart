---
slug: fold
title: fold — FxDart 101
description: Tutorial de fold en FxDart: reduce con un valor inicial explícito, seguro incluso con entrada vacía, con un playground en vivo.
heading: <code>fold</code>
section: 7
crumb: fold
prev: reduce.html
prevLabel: reduce
next: reduceLazy.html
nextLabel: reduceLazy
---
  <p class="hero-sub">La forma de reduce con valor inicial: siempre segura, incluso sobre un pipeline vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>fold</code> es <code><a href="reduce.html">reduce</a></code> con un
    valor inicial explícito. En FxTS esto es simplemente <code>reduce</code> llamado
    con tres argumentos — <code>reduce(f, seed, iterable)</code>. Dart no puede
    distinguir sobrecargas por el número de argumentos, así que FxDart separa las dos: la
    forma sin valor inicial conserva el nombre <code>reduce</code>, y la forma con valor inicial pasa a
    llamarse <code>fold</code>, igual que el nombre que el propio
    <code>Iterable</code> de Dart ya usa para esta misma operación.
  </p>
  <p>
    Fíjate bien en el orden de los argumentos: es <code>fold(seed, f, iterable)</code>
    — primero el valor inicial, luego el combinador y después la fuente — reflejando
    <code>Iterable.fold(initialValue, combine)</code> en la forma encadenada. Eso es
    distinto del <code>reduce(f, seed, iterable)</code> de FxTS, donde la
    función va primero.
  </p>
  <p>
    Como siempre aportas el valor inicial, <code>fold</code> nunca lanza sobre un
    iterable vacío: simplemente devuelve el valor inicial intacto. Eso lo convierte en la
    opción más segura siempre que no tengas la certeza de que el pipeline contenga algún
    elemento. Como <code>reduce</code>, es un operador terminal: nada de lo que hay
    aguas arriba se ejecuta hasta que <code>fold</code> tira de ello.
  </p>

  <h2>Demo 1 · Fundamentos &amp; entrada vacía</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, construyendo un Map</h2>
  <p>El valor inicial no tiene por qué ser un número: aquí plegamos un pipeline con retardo en un histograma de longitudes:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: pliega con <code>fold</code> los depósitos en un saldo acumulado, partiendo de <code>1000</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="reduce.html"><code>reduce</code></a> — la contraparte sin valor inicial ·
    <a href="reduceLazy.html"><code>reduceLazy</code></a> — un reductor currificado y reutilizable ·
    <a href="sum.html"><code>sum</code></a> — un fold habitual, ya especializado ·
    <a href="scan.html"><code>scan</code></a> — como fold, pero emite perezosamente cada valor intermedio
  </div>
