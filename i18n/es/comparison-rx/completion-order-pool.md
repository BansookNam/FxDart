---
slug: completion-order-pool
title: El resultado más rápido primero — RxDart vs FxDart
description: Imprimir cada resultado en cuanto aterriza — el orden de terminación es el comportamiento nativo de flatMap, y fxdart lo iguala con un operador dedicado concurrentPool.
heading: El resultado más rápido primero
order: 36
tier: 4
functions: fx, toAsync, map, concurrentPool
domain: users
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Ejecuta seis consultas de usuario con tiempos de respuesta distintos,
    como mucho <strong>3</strong> a la vez, y reporta los resultados en
    <strong>orden de terminación</strong> — la consulta más rápida se
    imprime primero, sin importar dónde estaba en la entrada. Los
    retardos están elegidos para que el orden sea estable (usuario 2,
    luego 1, 4, 3, 5, 6). Los datos están en el código; las dos versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Este es el reflejo especular del ejemplo anterior, y el veredicto se
    voltea a tablas. El orden de terminación es lo que una fusión
    <em>es</em>: el <code>flatMap(maxConcurrent: 3)</code> de RxDart se
    suscribe a tres streams internos y reenvía el que dispare primero,
    así que «el más rápido primero, de tres en tres» es el comportamiento
    literal del operador — nada que añadir, nada que deshacer.
  </p>
  <p>
    El comportamiento por defecto de un pipeline pull es el opuesto — los
    resultados vuelven en el orden en que se demandaron — así que FxDart
    ofrece el orden de terminación como variante con nombre:
    <code>concurrentPool(3)</code> mantiene tres pulls abiertos y entrega
    el que se resuelva primero, exactamente como la fusión. Cada
    biblioteca alcanza este requisito en un operador; la única diferencia
    real es qué comportamiento le sale gratis a cada modelo y a cuál
    tuvo que ponerle nombre. Elige según el orden que necesites —
    <code>mapConcurrent</code> cuando los resultados deben alinearse con
    las entradas, <code>flatMap</code> / <code>concurrentPool</code>
    cuando la latencia hasta el primer resultado importa más.
  </p>
