---
slug: fork
title: fork — FxDart 101
description: Tutorial de fork en FxDart: ramifica una única iteración con buffer de una fuente en varios lectores independientes, con un playground en vivo.
heading: <code>fork</code>
section: 6
crumb: fork
prev: reverse.html
prevLabel: reverse
next: reduce.html
nextLabel: reduce
---
  <p class="hero-sub">Ramifica una única iteración con buffer de una fuente en lectores independientes y reproducibles.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Iterar dos veces el mismo objeto <code>Iterable</code> de Dart normalmente
    ejecuta su fuente dos veces — un generador <code>sync*</code> vuelve a
    empezar desde cero cada vez que pides un <code>.iterator</code> nuevo. Eso
    es un derroche (o directamente un error) cuando producir un valor sale
    caro: una petición de red, un cálculo lento, un stream que solo puedes
    leer una vez. <code>fork</code> lo arregla: cada llamada a
    <code>fork(iterable)</code> con el <em>mismo</em> objeto
    <code>iterable</code> devuelve un cursor independiente sobre un único
    buffer compartido que crece de forma perezosa. La fuente subyacente se
    recorre exactamente una vez, sin importar cuántos forks lean de ella ni en
    qué orden.
  </p>
  <p>
    La compartición se indexa por la identidad del <code>iterable</code> que
    pasas (mediante un <code>Expando</code> interno), así que debes hacer fork
    del <em>mismo objeto</em> — no de dos iterables construidos por separado
    que casualmente se parezcan. Cada fork puede consumirse a su propio ritmo:
    adelantarse en un fork tira de nuevos valores de la fuente y los añade al
    buffer compartido; un fork que va rezagado simplemente reproduce los
    valores que ya están en el buffer, sin coste adicional.
    <code>forkAsync</code> funciona igual para <code>FxAsyncIterable</code> y,
    además, permite que la demanda concurrente de varios forks aguas abajo
    tire de la fuente asíncrona compartida en paralelo.
  </p>

  <h2>Demo 1 · Una fuente, dos ramas, demostrado con un contador</h2>
  <p>
    <code>source()</code> incrementa <code>calls</code> cada vez que produce
    un valor. Tanto <code>evens</code> como <code>doubled</code> hacen fork
    del mismísimo objeto <code>shared</code> — si la fuente se ejecutara dos
    veces, <code>calls</code> acabaría en 10, no en 5:
  </p>
  {{playground:0}}

  <h2>Demo 2 · Forks a ritmos distintos comparten un solo buffer</h2>
  <p>
    La rama <code>a</code> se adelanta y tira de dos valores nuevos; cuando la
    rama <code>b</code> pide sus dos primeros, simplemente reproduce lo que
    <code>a</code> ya había almacenado — sin nuevas llamadas a
    <code>source()</code> hasta que <code>b</code> necesita un tercer valor
    que ningún fork ha visto todavía:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: ahora mismo <code>readings</code> se itera dos veces sin
    <code>fork</code>, así que <code>sensor()</code> se ejecuta dos veces y
    <code>reads</code> acaba en 6. Haz fork de <code>readings</code> para cada
    consumidor de modo que el sensor se lea una sola vez (<code>reads</code>
    debería ser 3).
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="peek.html"><code>peek</code></a> — observar sin ramificar ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación paralela dentro de una sola rama ·
    <a href="memoize.html"><code>memoize</code></a> — cachear un único valor en lugar de una secuencia entera
  </div>
