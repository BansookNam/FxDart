---
slug: concurrent-enrichment
title: Enriquecer los principales comercios de forma concurrente — Dart vs FxDart
description: Elegir los 3 comercios principales y consultar cada uno en una API con límite de tasa, de dos en dos — un pool de workers hecho a mano en Dart nativo frente a concurrent(2) en FxDart.
heading: Enriquecer los principales comercios de forma concurrente
order: 30
tier: 3
functions: sortBy, take, toAsync, map, concurrent
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    A partir de los totales de gasto por comercio de julio, toma los
    <strong>tres comercios principales</strong> y enriquece cada uno con su
    categoría desde una API (simulada) de directorio de comercios —pero la
    API limita la tasa de peticiones, así que nunca puede haber más de
    <strong>dos consultas en curso a la vez</strong>. Los resultados se
    imprimen por orden de gasto cuando todas las consultas han terminado, y
    la consulta falsa cuenta las peticiones que se solapan para que ambas
    versiones puedan demostrar que el límite se respetó. Los datos están en
    el código de abajo; ambas versiones deben imprimir las líneas que
    aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La tarea cambia de naturaleza a mitad de camino —primero una
    clasificación síncrona, luego E/S con límite de tasa— y el código de
    solo una de las versiones cambia de naturaleza con ella. En FxDart la
    costura es un único paso de la cadena: <code>sortBy</code> +
    <code>take</code> eligen los comercios, <code>toAsync</code> cruza al
    mundo asíncrono, y <code>map</code> + <code>concurrent(2)</code>
    ejecutan las consultas de dos en dos, en orden. Dart nativo no tiene
    ninguna primitiva para «como mucho dos en curso»:
    <code>Future.wait</code> lo dispara todo a la vez, así que la mitad
    acotada se convierte en un pool de workers hecho a mano —cursor
    compartido, huecos de resultado predimensionados, futures de worker— que
    empequeñece la clasificación de dos líneas a la que sirve. Cambiar el
    límite, o eliminarlo, es un número en la cadena frente a todo ese
    andamiaje.
  </p>
