---
slug: bound-the-stall
title: Acotar la lectura atascada — RxDart vs FxDart
description: Un presupuesto de 150 ms sobre una lectura de sensor que se atasca — el timeout de stream vigila los huecos entre eventos, el timeout pull acota el tiempo demanda-a-elemento.
heading: Acotar la lectura atascada
order: 30
tier: 3
functions: fx, toAsync, map, timeout
domain: sensors
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Lee cuatro valores de sonda en secuencia; la tercera lectura se atasca
    durante 500&nbsp;ms. Da a cada lectura un presupuesto de
    150&nbsp;ms: imprime las lecturas que llegan a tiempo, luego
    <code>reading timed out</code> para el atasco, y
    <strong>detente</strong> — la cuarta lectura no debe reportarse. El
    atasco se inyecta de forma determinista en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El presupuesto por lectura en sí es fácil en ambos lados — el panel de
    RxDart acota el <code>Future</code> dentro de <code>asyncMap</code>,
    el <code>timeout</code> de FxDart acota el pull — así que la
    diferencia interesante es qué mide el operador <em>a nivel de
    stream</em> del mismo nombre en cada modelo.
    <code>Stream.timeout</code> vigila el hueco <strong>entre
    eventos</strong>: el productor decide cuándo llegan los valores, así
    que «demasiado lento» solo puede significar «hace rato que no llega
    nada». El <code>timeout</code> de FxDart acota el tiempo
    <strong>demanda-a-elemento</strong>: el consumidor pregunta, y el
    reloj corre desde la pregunta hasta la respuesta. En esta tarea finita
    y secuencial ambos coincidirían — pero son cantidades genuinamente
    distintas: un pipeline pull sin demanda no tiene huecos que medir, y
    un stream push no le debe respuesta a la pregunta de nadie.
  </p>
  <p>
    Cada lado necesita entonces un arruga real para cumplir la cláusula
    «y detente». En el lado push la fuente atascada sigue ahí fuera, y
    volvería a empujar lecturas en cuanto la lectura lenta por fin
    aterrizara — así que después de que <code>onErrorReturnWith</code>
    convierta el error en la línea del informe,
    <code>takeWhileInclusive</code> termina el stream y cancela la
    suscripción. En el lado pull detenerse es gratis — la
    <code>TimeoutException</code> simplemente sale del bucle y nada
    vuelve a tirar — pero conservar las lecturas que precedieron al
    atasco significa recolectar con <code>each</code> en lugar de un
    <code>toList</code> que las habría descartado al lanzar.
  </p>
  <p>
    Un empate: un operador más una arruga en cada lado, y las arrugas son
    imágenes especulares de la naturaleza de cada modelo.
  </p>
