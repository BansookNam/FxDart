---
slug: consume
title: consume — FxDart 101
description: Tutorial de consume en FxDart: fuerza los efectos secundarios de una cadena perezosa sin recopilar ningún valor, con un límite opcional.
heading: <code>consume</code>
section: 1
crumb: consume
prev: each.html
prevLabel: each
next: range.html
nextLabel: range
---
  <p class="hero-sub">Tira de los valores a través de una cadena y los descarta — solo por sus efectos secundarios, con tope opcional.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>consume</code> es el operador terminal mínimo: tira de los valores a
    través de la cadena — ejecutando por sus efectos secundarios los pasos
    <code>peek</code> o <code>mapEffect</code> que haya aguas arriba — pero
    descarta cada valor en lugar de recopilarlo o reenviarlo. Recurre a él
    cuando todo el sentido de un pipeline son sus efectos secundarios y
    construir una <code>List</code> con <code>toList</code> sería tan solo
    reservar memoria para nada.
  </p>
  <p>
    El <code>n</code> opcional lo convierte en la pareja natural de las fuentes
    infinitas o enormes: <code>consume(5)</code> tira exactamente de 5 valores y
    se detiene, aunque el iterable subyacente (<code>range</code> sin límite,
    <code>cycle</code>, <code>repeat</code> con una cuenta enorme) siguiera
    indefinidamente. Omite <code>n</code> para vaciar por completo un iterable
    finito.
  </p>
  <p>
    <code>consumeAsync</code> (o <code>.consume()</code> sobre una cadena
    <code>FxAsync</code>) funciona igual, esperando por turno los efectos
    secundarios de cada valor del que tira — práctico para forzar que un
    pipeline asíncrono de <code>peek</code>/logging se ejecute de verdad sin
    pagar el coste de recopilar una lista de resultados que ibas a tirar de
    todos modos.
  </p>

  <h2>Demo 1 · Acotar una fuente infinita</h2>
  <p>
    <code>range(1000000)</code> normalmente no terminaría nunca si se consumiera
    entero — pero <code>consume(5)</code> se para tras 5 elementos:
  </p>
  {{playground:0}}

  <h2>Demo 2 · Efectos secundarios asíncronos, sin lista de resultados</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: consume solo los 3 primeros valores de un <code>repeat()</code>
    prácticamente infinito, registrando cada uno conforme se tira de él.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="each.html"><code>each</code></a> — operador terminal que también ejecuta f, sin el atajo del límite n ·
    <a href="toList.html"><code>toList</code></a> — operador terminal que en cambio recopila los resultados ·
    <a href="cycle.html"><code>cycle</code></a> — una fuente infinita que suele acompañar a consume ·
    <a href="peek.html"><code>peek</code></a> — el paso perezoso de efecto secundario que consume normalmente fuerza
  </div>
