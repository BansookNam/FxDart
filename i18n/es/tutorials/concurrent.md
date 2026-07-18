---
slug: concurrent
title: concurrent — FxDart 101
description: Tutorial de concurrent en FxDart: evalúa n elementos asíncronos a la vez preservando el orden, con el modelo de marcador de concurrencia y un playground en vivo.
heading: <code>concurrent</code>
section: 11
crumb: concurrent
next: concurrentPool.html
nextLabel: concurrentPool
---
  <p class="hero-sub">Evalúa hasta n elementos de un pipeline asíncrono a la vez, y aun así los resultados llegan en el orden de la fuente.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>concurrent(n)</code> es la respuesta de FxDart a "ejecuta varios pasos
    asíncronos en paralelo, pero mantén los resultados en orden". Funciona
    mediante el modelo de <strong>marcador de concurrencia</strong> integrado en
    <code>FxAsyncIterator.next([Concurrent? concurrent])</code>: cuando llamas a
    <code>.concurrent(3)</code>, cada pull que lo atraviesa propaga un marcador
    <code>Concurrent(3)</code> <em>aguas arriba</em>, capa a capa, diciéndole a
    quien produzca los valores "evalúa 3 de golpe en vez de uno". El operador de
    aguas arriba — normalmente un <code>map</code> perezoso — ve ese marcador y, en
    lugar de esperar un Future y después arrancar el siguiente, llama tres veces
    al <code>next()</code> de su propia fuente sin esperar entre medias, de modo
    que hay tres Futures en vuelo a la vez. A medida que cada uno se resuelve,
    <code>concurrent</code> guarda el resultado en un búfer pero solo <em>te</em>
    entrega valores en el orden original — así que los resultados siempre salen
    respetando la secuencia de entrada, aunque un elemento posterior termine
    antes que uno anterior.
  </p>
  <p>
    Este es el canal de retorno que mencionaba la lección de <code>toAsync</code>:
    el <code>Stream</code> de Dart no tiene forma de pedirle a posteriori a una
    fuente de aguas arriba "dame 3 a la vez", porque un <code>Stream</code> empuja los
    valores a su propio ritmo. El protocolo <code>next()</code> basado en pull de
    FxDart lleva esa petición aguas arriba en cada pull, y eso es justamente lo
    que hace posible <code>concurrent(n)</code>.
  </p>
  <p>
    Ajusta <code>n</code> según lo que te limite: una API REST puede tolerar de 5
    a 10 peticiones concurrentes, una tarea local limitada por CPU querrá una
    <code>n</code> cercana a tu número de núcleos, y <code>n = 1</code> equivale
    a esperar secuencialmente sin más (que es exactamente lo que obtienes sin
    <code>concurrent</code>).
  </p>

  <h2>Demo 1 · Secuencial vs. concurrent(3), cronometrado</h2>
  <p>Seis elementos, cada uno con 200ms de retardo. En secuencia tarda ~1200ms;
    pidiendo 3 a la vez baja a ~400ms:</p>
  {{playground:0}}

  <h2>Demo 2 · El orden se preserva, aunque el de finalización no</h2>
  <p>
    Aquí el elemento 2 termina antes que el 1 (100ms frente a 300ms), pero
    <code>concurrent(3)</code> sigue devolviendo los resultados en el orden de la
    fuente — compáralo con <a href="concurrentPool.html"><code>concurrentPool</code></a>,
    que hace justo lo contrario:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: este pipeline procesa 6 elementos de 200ms cada uno, de forma
    secuencial (<code>n = 1</code>). Sube <code>n</code> y observa cómo cae el
    tiempo transcurrido — prueba con <code>3</code> y luego con <code>6</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — variante por orden de finalización ·
    <a href="toAsync.html"><code>toAsync</code></a> — el modelo basado en pull en el que se apoya ·
    <a href="asyncVariants.html">variantes asíncronas</a> — la convención de nombres *Async ·
    <a href="map.html"><code>map</code></a> — el operador que más a menudo acompaña a concurrent
  </div>
