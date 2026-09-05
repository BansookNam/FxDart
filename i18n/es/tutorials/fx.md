---
slug: fx
title: fx — FxDart 101
description: Tutorial de fx en FxDart: el modelo de cadenas perezosas — fx, fxAsync, fxStream — y por qué nada se ejecuta hasta que un operador terminal tira de los valores.
heading: <code>fx</code>
section: 1
crumb: fx
prev: whichSurface.html
prevLabel: which surface
next: pipe.html
nextLabel: pipe
---
  <p class="hero-sub">Envuelve una secuencia en un pipeline perezoso y encadenable: el corazón tipado de FxDart.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Todo este curso apunta a una sola idea: la <strong>cadena</strong>.
    <code>fx(iterable)</code> envuelve cualquier <code>Iterable&lt;T&gt;</code> en un
    <code>Fx&lt;T&gt;</code>: un objeto con métodos al estilo de FxTS como
    <code>.map()</code>, <code>.filter()</code> y <code>.take()</code>
    colgando de él. Cada una de esas llamadas devuelve un <em>nuevo</em>
    <code>Fx</code> que envuelve un poco más de cómputo perezoso. Nada se
    ejecuta todavía. <code>Fx</code> solo empieza a trabajar cuando llamas a un
    <strong>operador terminal</strong> — <code>toList()</code>,
    <code>each()</code>, <code>consume()</code>, <code>reduce()</code> y
    compañía —, que tira de los valores a través de toda la cadena, uno a uno,
    desde el terminal hasta la fuente.
  </p>
  <p>
    Esta pereza es lo que permite a FxDart encadenar sin riesgo sobre secuencias
    enormes o infinitas (<code>range</code>, <code>cycle</code>, <code>repeat</code>):
    mientras algo aguas abajo — normalmente <code>take(n)</code> — decida
    cuántos valores pedir de verdad, los pasos de aguas arriba solo se
    ejecutan esas veces.
  </p>
  <p>
    <code>fx</code> es la mitad <em>síncrona</em> de la cadena. Sus equivalentes
    asíncronos son <code>fxAsync</code>, que envuelve un
    <code>FxAsyncIterable</code> (lo que obtienes de <code>toAsync</code>,
    <code>fromStream</code> o cualquier función <code>*Async</code>), y
    <code>fxStream</code>, un atajo que envuelve directamente un <code>Stream</code>
    de Dart. Ambos devuelven una cadena <code>FxAsync&lt;T&gt;</code> cuyos
    métodos aceptan funciones que pueden devolver un <code>Future</code>, y
    cuyos operadores terminales devuelven todos un <code>Future</code> que
    esperas con <code>await</code>. Pasa de síncrono a asíncrono a mitad de cadena con
    <code>.toAsync()</code>.
  </p>
  <p>
    ¿Y por qué existe esto, en lugar de llamar sin más a funciones de nivel
    superior como <code>map(f, iterable)</code>? Porque Dart no puede tipar un
    <code>pipe</code> variádico como sí hace TypeScript en FxTS (lo verás en la
    siguiente lección): el encadenado con <code>fx()</code> es la forma que tiene
    FxDart de ofrecer pipelines totalmente tipados y con autocompletado.
  </p>

  <div class="callout">
    <strong>Cambio incompatible en 0.8.0:</strong>
    <code>Fx&lt;T&gt;</code> ahora es un <strong>extension type</strong> que en
    tiempo de ejecución se borra al <code>Iterable&lt;T&gt;</code> que envuelve.
    Todas las APIs documentadas siguen igual: las cadenas funcionan exactamente
    como antes. Lo que se rompe: las comprobaciones
    <code>x is Fx&lt;T&gt;</code> (el tipo no existe en tiempo de ejecución) y el
    código que intentaba extender o implementar <code>Fx</code> directamente (usa
    las funciones de nivel superior en su lugar). Si usas <code>fx()</code> de la
    forma habitual, no tienes que cambiar nada.
  </div>

  <h2>Demo 1 · Nada se ejecuta hasta el operador terminal</h2>
  <p>Fíjate en que <code>calls</code> se queda en 0 justo después de construir la cadena, y
    salta en cuanto <code>toList()</code> tira de verdad de los 5 valores:</p>
  {{playground:0}}

  <h2>Demo 2 · fxAsync y fxStream</h2>
  <p>
    <code>fxAsync</code> envuelve un <code>FxAsyncIterable</code> (aquí, desde
    <code>toAsync</code>); <code>fxStream</code> envuelve un <code>Stream</code>
    directamente. Ambos te dan los mismos métodos de cadena, en versión asíncrona:
  </p>
  {{playground:1}}

  <h2>La forma con getter</h2>
  <p>
    Cada punto de entrada existe también como getter: <code>.fx</code> sobre un
    <code>Iterable</code>, un <code>FxAsyncIterable</code> o un
    <code>Stream</code>, <code>.fxAsync</code> sobre un iterable de futuros y
    <code>.fxEvents</code> sobre un <code>Stream</code>. Construyen exactamente
    la misma cadena; lo único que cambia es por qué extremo de la expresión se
    empieza a leer:
  </p>
  <pre><code>// la función: hay que volver al principio para abrir el paréntesis
fx(orders.where(isPaid)).groupBy((o) =&gt; o.customerId);

// el getter: de izquierda a derecha, como se lee .toList()
orders.where(isPaid).fx.groupBy((o) =&gt; o.customerId);</code></pre>
  <p>
    Esta es la forma idiomática en Dart, y es gratis: <code>Fx</code> es un
    extension type, así que el envoltorio se borra y queda el iterable mismo, y
    un getter cuyo cuerpo es <code>this</code> es una llamada estática que el
    compilador elimina. Sobre un <code>map</code> + <code>filter</code> +
    <code>sum</code> de un millón de elementos, ambas formas miden 12.640 ms y
    12.665 ms — el mismo número dos veces.
  </p>
  <p>
    <strong>Estas páginas usan <code>fx()</code> en todo momento.</strong> Es el
    nombre que usa FxTS y es el que admite un argumento de tipo explícito, algo
    que un getter no puede recibir en posición posfija:
    <code>fx&lt;num&gt;(xs)</code> funciona donde
    <code>xs.fx&lt;num&gt;</code> ni siquiera parsea. En tu propio código elige
    la que mejor se lea; compilan a lo mismo.
  </p>
  <p>
    Conviene conocer una asimetría. Sobre un
    <code>Iterable&lt;Future&lt;T&gt;&gt;</code>, <code>.fx</code> devuelve un
    <code>Fx&lt;Future&lt;T&gt;&gt;</code> — una cadena sobre los futuros y no
    sobre sus valores, que compila y hace lo incorrecto en silencio. Para eso
    está <code>.fxAsync</code>: los espera, de modo que <code>T</code> es el
    tipo resuelto y <code>concurrent(n)</code> tiene algo que hacer.
  </p>
  <pre><code>await responses.fxAsync.map(parse).concurrent(4).toList();</code></pre>
  <p>
    Un <code>Stream</code> lleva ambos getters, porque es la única fuente que
    pertenece a los dos mundos. <code>.fx</code> da la cadena <em>pull</em>, lo
    mismo que <code>fxStream</code>; <code>.fxEvents</code> da la cadena
    <em>push</em>, lo mismo que <a href="fxEvents.html"><code>fxEvents</code></a> —
    debounce, throttle, switch. Para volver de push a pull,
    <code>.pull()</code>. Se comparan lado a lado en
    <a href="streams.html">Puentes de Stream</a>.
  </p>
  <pre><code>keystrokes.fxEvents
    .debounce(const Duration(milliseconds: 160))
    .switchMap((q) =&gt; search(q).asStream())
    .pull()
    .toList();</code></pre>

  <h2>Todas las formas con getter</h2>
  <p>
    La convención es una sola regla: un punto de entrada lleva <code>fx</code>
    en el nombre. Dice en qué librería estás entrando y deja el nombre desnudo
    — <code>toAsync</code>, <code>shuffle</code>, <code>debounce</code> —
    libre para lo que el proyecto quiera poner en ese tipo.
  </p>
  <table>
    <thead><tr><th>Receptor</th><th>Getter</th><th>Equivale a</th></tr></thead>
    <tbody>
      <tr><td><code>Iterable&lt;T&gt;</code></td><td><code>.fx</code></td><td><code>fx(xs)</code></td></tr>
      <tr><td><code>FxAsyncIterable&lt;T&gt;</code></td><td><code>.fx</code></td><td><code>fxAsync(it)</code></td></tr>
      <tr><td><code>Stream&lt;T&gt;</code></td><td><code>.fx</code></td><td><code>fxStream(s)</code></td></tr>
      <tr><td><code>Iterable&lt;FutureOr&lt;T&gt;&gt;</code></td><td><code>.fxAsync</code></td><td><a href="toAsync.html"><code>toAsync(xs)</code></a></td></tr>
      <tr><td><code>Stream&lt;T&gt;</code></td><td><code>.fxEvents</code></td><td><a href="fxEvents.html"><code>fxEvents(s)</code></a></td></tr>
      <tr><td><code>Stream&lt;T&gt;</code></td><td><code>.fxLive</code></td><td><a href="liveValue.html"><code>LiveValue.from(s)</code></a></td></tr>
      <tr><td><code>Stream&lt;T&gt;</code></td><td><code>.fxLiveSeeded</code></td><td><a href="liveValue.html"><code>LiveValue.seededFrom(v, s)</code></a></td></tr>
      <tr><td><code>Iterable&lt;T&gt;</code></td><td><code>.fxShuffle</code></td><td><a href="shuffle.html"><code>shuffle(xs)</code></a></td></tr>
      <tr><td><code>FxAsyncIterable&lt;T&gt;</code></td><td><code>.fxShuffle</code></td><td><a href="shuffle.html"><code>shuffleAsync(it)</code></a></td></tr>
      <tr><td><code>void Function(T)</code></td><td><code>.fxDebounce</code></td><td><a href="debounce.html"><code>debounce(f, w)</code></a></td></tr>
      <tr><td><code>void Function(T)</code></td><td><code>.fxThrottle</code></td><td><a href="throttle.html"><code>throttle(f, w)</code></a></td></tr>
    </tbody>
  </table>
  <p>
    Los operadores no están en esta lista, y no lo estarán. Quince de ellos —
    <code>map</code>, <code>where</code>, <code>take</code>,
    <code>fold</code> y compañía — comparten nombre con un miembro que
    <code>Iterable</code> ya tiene, y un miembro de instancia siempre gana a
    una extensión, así que esas llamadas nunca podrían llegar a fxdart. Los
    operadores viven en la cadena: <code>xs.fx.map(f)</code>, no
    <code>xs.map(f)</code>.
  </p>

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: construye una cadena que se quede con las puntuaciones de 60 o más, las duplique
    como puntos extra y tome solo los 2 primeros resultados.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pipe.html"><code>pipe</code></a> — la alternativa de tipado dinámico ·
    <a href="toList.html"><code>toList</code></a> — el operador terminal más habitual ·
    <a href="each.html"><code>each</code></a> — operador terminal para efectos secundarios ·
    <a href="consume.html"><code>consume</code></a> — operador terminal que descarta los resultados
  </div>
