---
slug: tee
title: tee — FxDart 101
description: Tutorial de tee en FxDart: ejecuta dos o tres folds sobre una sola pasada de la fuente, sin almacenar nada, con playground en vivo.
heading: <code>tee</code>
section: 6
crumb: tee
prev: fork.html
prevLabel: fork
next: tee3.html
nextLabel: tee3
---
  <p class="hero-sub">Ejecuta varios folds sobre una pasada de la fuente: una iteración, nada almacenado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Dos preguntas sobre los mismos datos suelen costar dos pasadas:
    <code>readings.fold(...)</code> para el total y luego
    <code>readings.reduce(...)</code> para el pico. Eso está bien para una
    <code>List</code>, y está mal para cualquier otra cosa: un generador
    <code>sync*</code>, una página de red o una fuente que cuenta cuántas
    veces se ejecutó se recorrerán dos veces. <code>tee</code> hace las dos
    preguntas a la vez: cada elemento hace avanzar el total <em>y</em> el pico
    antes de tirar del siguiente, así que la fuente se recorre exactamente una
    vez.
  </p>
  <p>
    Un lector se da como un <strong>fold</strong>: un record con
    <code>seed</code> (dónde empieza) y <code>step</code> (cómo lo hace
    avanzar un elemento). Esa forma es lo que hace gratis la pasada única.
    Como los dos lectores se mueven juntos, elemento a elemento, nunca hay un
    valor que uno haya visto y el otro no, así que no hay nada que recordar:
    <code>tee</code> sobre un millón de elementos sostiene dos acumuladores,
    no un millón de valores. Los dos acumuladores son totalmente
    independientes y no tienen por qué compartir tipo. <a href="tee3.html"><code>tee3</code></a> admite tres.
  </p>
  <p>
    La restricción es el precio de eso. <code>tee</code> alimenta folds, no
    pipelines: los lectores no pueden avanzar a su propio ritmo, tomar
    cantidades distintas ni pararse antes por su cuenta. Cuando de verdad
    necesitas dos lectores <em>independientes</em>, echa mano de
    <a href="fork.html"><code>fork</code></a> y acepta el búfer compartido que
    mantiene para que un cursor rezagado pueda alcanzar al otro. Regla
    práctica: si los dos lectores consumen la fuente entera y la reducen a un
    valor, <code>tee</code>; si alguno es un pipeline por derecho propio,
    <code>fork</code>.
  </p>

  <h2>De dónde viene el nombre</h2>
  <p>
    <code>tee</code> no es una abreviatura: es la letra <strong>T</strong>,
    tomada de la pieza en T de la fontanería. Un empalme en T divide una
    tubería en dos, así que lo que entra por un lado sale por dos a la vez.
    Unix se quedó con la imagen para su orden <code>tee</code>, que lee la
    entrada estándar y la envía a la salida estándar <em>y</em> a un fichero
    al mismo tiempo:
  </p>
  <pre><code>       input
        │
        ▼
    ┌───┴───┐
    │  tee  │
    └───┬───┘
   ┌────┴────┐
   ▼         ▼
  stdout    file</code></pre>
  <p>
    El <code>itertools.tee()</code> de Python toma prestada la misma imagen,
    dividiendo un iterable en varios iteradores independientes. Conviene
    saberlo, porque esa es la parte que FxDart llama
    <a href="fork.html"><code>fork</code></a>, no <code>tee</code>:
    <code>fork</code> te da cursores independientes, como el de Python. El
    <code>tee</code> de FxDart ramifica el <em>consumo</em> en su lugar: una
    pasada, varios folds leyéndola al unísono. La misma imagen en forma de T,
    dividida un nivel más aguas abajo.
  </p>

  <h2>Demo 1 · Total y pico con una sola lectura</h2>
  <p>
    <code>sensor()</code> incrementa <code>reads</code> por cada valor que
    produce. Dos pasadas separadas dejarían <code>reads</code> en 12;
    <code>tee</code> lo deja en 6:
  </p>
  {{playground:0}}

  <h2>Demo 2 · Acumuladores independientes, tee3, y sobre una cadena</h2>
  <p>
    Los dos folds llevan tipos que no tienen nada que ver: un recuento de
    caracteres <code>int</code> junto a un <code>String</code> con el ganador
    provisional. <code>tee3</code> añade un tercer fold y, sobre una cadena
    <code>fx</code>, los folds ven lo que produce la <em>cadena</em>, no la
    fuente original:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: ahora mismo <code>sensor()</code> se recorre dos veces, así que
    <code>reads</code> imprime 6. Sustituye las dos pasadas por un solo
    <code>tee</code> — sumando en un fold y contando en el otro — para que
    <code>reads</code> imprima 3.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fork.html"><code>fork</code></a> — lectores independientes, a costa de un búfer ·
    <a href="reduce.html"><code>reduce</code></a> — un solo fold ·
    <a href="groupBy.html"><code>groupBy</code></a> — muchos acumuladores indexados por valor
  </div>
