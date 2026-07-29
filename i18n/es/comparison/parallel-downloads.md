---
slug: parallel-downloads
title: Descargas en paralelo, resultados en orden — Dart vs FxDart
description: Seis descargas con velocidades distintas, 3 a la vez — concurrent mantiene el orden de las peticiones aunque las finalizaciones se entrelacen, frente a la contabilidad de un pool.
heading: Descargas en paralelo, resultados en orden
order: 46
tier: 4
functions: toAsync, map, concurrent, zipWithIndex, join, sumBy
domain: general
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Descarga seis archivos — cada uno con un tamaño fijo y un tiempo de
    transferencia fijo (simulado), en el código de abajo — con como mucho
    <strong>tres descargas en vuelo</strong>, y lista los resultados
    numerados <strong>en el orden en que se pidieron</strong>. Los
    retardos están elegidos para que las finalizaciones se entrelacen: el
    <code>video.mp4</code> de 30&nbsp;ms se pide primero, pero el
    <code>notes.txt</code> de 10&nbsp;ms termina antes. Ambas versiones
    imprimen qué archivo terminó primero y la concurrencia máxima
    observada — la prueba de que el trabajo se solapó de verdad, fuera de
    orden, mientras el listado se mantenía en orden.
  </p>
  <p>
    Esa garantía de reordenar por dentro y conservar el orden en la
    superficie es justo lo que hace <code>concurrent(3)</code>: evalúa
    hasta tres elementos aguas arriba a la vez y aun así entrega los
    resultados en el orden de la fuente. La cadena los numera con
    <code>zipWithIndex</code> y monta el informe con <code>join</code>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    <code>Future.wait</code> conserva el orden, pero descarga todo a la
    vez — sin límite. Añadir el límite es lo que obliga a montar el pool
    de workers nativo, y conservar el orden bajo ese pool es precisamente
    la parte sutil: la lista <code>results</code> predimensionada e
    indexada por un cursor compartido. Si te equivocas en la contabilidad
    de las posiciones, los resultados vuelven desordenados — un bug que
    solo se manifiesta cuando el orden de finalización resulta ser
    distinto del orden de petición, algo que depende de los tiempos y es
    fácil que se escape en los tests. En FxDart la garantía de orden es el
    contrato del operador, no tu código: <code>concurrent(3)</code> no
    puede devolver elementos desordenados, caigan como caigan los tiempos.
  </p>
