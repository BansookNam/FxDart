---
slug: stop-after-three-failures
title: Rendirse tras tres fallos — RxDart vs FxDart
description: Contar fallos con scan y parar en el tercero, inclusive — un try/catch en el mapper vs convertir los errores en valores marcadores antes de que scan pueda verlos.
heading: Rendirse tras tres fallos
order: 27
tier: 3
functions: fx, toAsync, map, scan, takeUntilInclusive
domain: logs
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un feed de diez sondas de salud corre en orden; las sondas 2, 5, 7, 8
    y 9 lanzan. Detén la ejecución en el momento en que se vea el
    <strong>tercer</strong> fallo (incluyéndolo), y luego imprime tres
    conteos: <em>processed</em> — sondas que entraron al pipeline antes
    del corte; <em>failures</em> — cuántas de esas lanzaron; y
    <em>probes run</em> — cuerpos de sonda realmente ejecutados,
    contabilizados por un contador de efecto colateral dentro de la
    propia sonda. Las sondas posteriores no deben ejecutarse jamás, así
    que el conteo de ejecuciones tiene que coincidir con el de
    procesadas. El calendario está en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El núcleo de conteo es el mismo en ambos lados — <code>scan</code>
    pliega un estado acumulado <code>(done, fails)</code>, y un operador
    take-inclusivo corta el pipeline en el tercer fallo
    (<code>takeUntilInclusive(fails == 3)</code> en un lado,
    <code>takeWhileInclusive(fails &lt; 3)</code> en el otro). Ambos
    además detienen el trabajo de verdad: <code>probes run: 7</code>
    demuestra que cancelar la suscripción y dejar de tirar son frenos
    igual de efectivos.
  </p>
  <p>
    La diferencia es lo que cada lado tuvo que hacer <em>antes</em> de
    que scan pudiera contar. Una sonda que lanza vive en el canal de
    errores del stream, donde scan no puede verla — y donde terminaría el
    stream en el fallo número uno. Así que el lado RxDart primero
    convierte cada sonda en un stream interno
    (<code>Rx.fromCallable</code> + <code>onErrorReturn(false)</code>)
    para contrabandear los fallos de vuelta al canal de datos como
    valores marcadores. El lado FxDart no necesita paso de conversión,
    porque no hay nada <em>desde</em> lo que convertir: un try/catch
    dentro de <code>map</code> hace del desenlace un <code>bool</code>
    justo donde ocurre, y el resto del pipeline es aritmética. Los mismos
    operadores, una frontera de modelo menos que cruzar.
  </p>
