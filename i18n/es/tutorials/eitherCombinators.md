---
slug: eitherCombinators
title: Either combinators — FxDart 101
description: Tutorial de los combinadores de Either en FxDart: de map2 a map5, más alt, orElse y filterOrElse, con playground en vivo.
heading: <code>Either</code> combinators
section: 13
crumb: Either combinators
prev: either.html
prevLabel: Either
next: raise.html
nextLabel: either &amp; Raise
---
  <p class="hero-sub">Combinar, recurrir a una alternativa y validar: <code>map2</code>…<code>map5</code>, <code>alt</code>, <code>orElse</code>, <code>filterOrElse</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <a href="either.html"><code>Either</code></a> por sí solo te da
    <code>map</code>, <code>flatMap</code> y <code>fold</code>. Estos cuatro
    métodos cubren las formas que acababan convirtiéndose en un
    <code>flatMap</code> con un <code>if</code> dentro.
  </p>

  <h3><code>map2</code> … <code>map5</code>: combinar resultados independientes</h3>
  <p>
    Cuando varios <code>Either</code> tienen que salir bien a la vez —
    parsear un nombre <em>y</em> una edad <em>y</em> un email —,
    <code>map2</code> los combina y conserva el fallo <strong>más a la
    izquierda</strong>. El callback combinador solo se ejecuta cuando todas
    las ramas son <code>Right</code>. Las aridades llegan hasta cinco, el
    mismo tope que
    <a href="accumulate.html"><code>zipOrAccumulate2..5</code></a> y
    <code>Curry2..Curry5</code>.
  </p>
  <p>
    Aquí «fallar rápido» va del <em>informe</em>, no del trabajo. Las ramas
    son valores que ya calculaste, así que todas se ejecutaron; lo que se
    detiene en el primer fallo es la respuesta que recibes. Cuando quieres
    todos los fallos — un formulario que marca los cuatro campos malos de
    una vez —, eso es <a href="accumulate.html">acumulación</a>, que informa
    con un <code>EitherNel</code> y necesita un ámbito
    <code>accumulate</code>. Recurre a <code>map2</code> cuando un solo
    mensaje es la respuesta correcta.
  </p>

  <h3><code>alt</code> y <code>orElse</code>: recurrir a una alternativa</h3>
  <p>
    <code>alt</code> es la escalera de alternativas: prueba esto y, si falló,
    prueba aquello. La alternativa es un callback, así que no se toca nada más
    allá del primer acierto — caché, luego disco, luego red, pagando solo por
    lo que de verdad alcanzas. El fallo se descarta.
  </p>
  <p>
    <code>orElse</code> es el mismo movimiento para cuando el fallo importa:
    el manejador lo recibe y puede devolver un tipo de fallo distinto, así que
    también es como se traduce un vocabulario de errores a otro.
  </p>
  <p>
    <a href="raise.html"><code>recover</code></a> es el hermano más rico.
    Ejecuta el manejador dentro de un ámbito raise nuevo, de modo que el
    manejador escribe Dart normal y llama a <code>r.raise</code> en lugar de
    construir un <code>Either</code> a mano. Usa
    <code>alt</code>/<code>orElse</code> cuando el <code>Either</code> de
    reemplazo ya existe, y <code>recover</code> cuando el manejador tiene
    trabajo de verdad.
  </p>

  <h3><code>filterOrElse</code>: validar sobre la marcha</h3>
  <p>
    Degrada un <code>Right</code> cuyo valor falla un predicado a un
    <code>Left</code> que el segundo callback construye <em>a partir de ese
    valor</em>, de modo que el mensaje puede nombrar qué estaba mal. Un
    <code>Left</code> pasa intacto y el predicado nunca se ejecuta.
    Encadénalos y gana la primera comprobación que falle.
  </p>
  <p>
    Es la forma sobre un valor <code>Either</code> de
    <a href="raise.html"><code>Raise.ensure</code></a>, que hace el mismo
    trabajo dentro de un constructor <code>either { }</code>. Dentro de un
    constructor, prefiere <code>ensure</code>; sobre un valor que ya tienes en
    la mano, esto.
  </p>

  <h2>Demo 1 · map2 y map3</h2>
  {{playground:0}}

  <h2>Demo 2 · alt, orElse, filterOrElse</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: rechaza una edad fuera de 0..149, con un mensaje tuyo.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="either.html"><code>Either</code></a> — el tipo que estos extienden ·
    <a href="raise.html"><code>either</code> &amp; <code>Raise</code></a> — ámbito constructor, <code>ensure</code> y <code>recover</code> ·
    <a href="accumulate.html">acumulación</a> — todos los fallos en vez del primero ·
    <a href="eitherPipelines.html">Either × pipelines</a> — llevar Eithers a través de una cadena
  </div>
