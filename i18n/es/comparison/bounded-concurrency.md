---
slug: bounded-concurrency
title: Obtener perfiles de dos en dos — Dart vs FxDart
description: Concurrencia acotada y en orden — un pool de workers hecho a mano en Dart nativo frente a toAsync + map + concurrent en FxDart.
heading: Obtener perfiles de dos en dos
order: 15
tier: 2
functions: toAsync, map, concurrent
domain: users
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Obtén seis perfiles de usuario de una API (simulada), pero sin superar
    nunca <strong>dos peticiones en curso a la vez</strong>: la API limita la
    tasa de peticiones. Los resultados deben volver <strong>en el orden
    original</strong>. Para demostrar que el límite se respetó, la petición
    falsa cuenta cuántas peticiones se solapan y ambas versiones imprimen el
    máximo observado.
  </p>
  <p>
    Esta es la tarea para la que Dart nativo no tiene ninguna primitiva.
    <code>Future.wait</code> lo lanza <em>todo</em> a la vez; agrupar en
    parejas desperdicia tiempo esperando a la más lenta de cada pareja;
    hacerlo bien significa escribir un pool de workers a mano —llevar la
    cuenta de los índices, un cursor compartido, huecos de resultado
    predimensionados—. El <code>.concurrent(2)</code> de FxDart es ese pool
    de workers, en una sola palabra: en cuanto termina una petición arranca
    la siguiente, y el orden se conserva.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Las dos versiones imprimen lo mismo —la diferencia está en lo que has
    tenido que escribir y en lo que ahora tienes que mantener. El pool de
    workers nativo es boilerplate de producción de verdad (y es fácil
    equivocarse sutilmente: un off-by-one en el cursor compartido, olvidar
    predimensionar la lista de resultados, perder el orden). En la versión
    de FxDart la política de concurrencia es un único paso de la cadena, así
    que cambiar el límite —o quitarlo— toca un número en lugar de toda la
    forma de la función.
  </p>
