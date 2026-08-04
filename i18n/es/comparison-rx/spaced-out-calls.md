---
slug: spaced-out-calls
title: Una llamada cada 100 ms — RxDart vs FxDart
description: Cinco pings separados al menos 100 ms, probado con un Stopwatch monotónico — el interval de rx vs un delay llano en el mapper de una cadena pull secuencial.
heading: Una llamada cada 100 ms
order: 42
tier: 4
functions: fx, toAsync, map
alsoLink: streams
domain: general
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Envía cinco pings a un endpoint con límite de tasa, cada uno
    empezando al menos <strong>100&nbsp;ms</strong> después del anterior.
    Registra el arranque de cada llamada en un <code>Stopwatch</code>
    monotónico, imprime las cinco respuestas, e imprime
    <code>spaced: true</code> solo si todos los huecos respetaron el
    límite. Las dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El espaciado va de tiempo, así que cabría esperar que el stream
    ganara — y RxDart sí tiene la palabra para ello:
    <code>interval</code> retiene cada evento 100&nbsp;ms antes de que
    llegue al ping, y el backpressure mantiene todo el asunto secuencial.
    Un operador, requisito cumplido.
  </p>
  <p>
    Pero un pipeline pull es secuencial por defecto, y eso convierte el
    espaciado en algo casi vergonzosamente simple: pon el delay
    <em>dentro del mapper</em>. Cada pull espera 100&nbsp;ms y luego
    llama — el siguiente pull no puede empezar hasta que este termine,
    así que el espaciado es estructural, sin operador alguno. La
    comprobación con Stopwatch imprime <code>spaced: true</code> en ambos
    lados. Llámalo un empate con una salvedad por bando: RxDart nombra el
    concepto explícitamente, lo que se lee mejor en un pipeline lleno de
    otros operadores de tiempo; a FxDart le sale como consecuencia de una
    línea de la demanda, pero solo porque esta tarea quiere llamadas
    estrictamente seriales — para espaciar eventos que llegan con su
    propio calendario (un stream de eventos real), acude al lado stream
    del puente (<code>fxStream</code>) y al vocabulario temporal de
    RxDart.
  </p>
