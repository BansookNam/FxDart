---
slug: debounced-search
title: Aplicar debounce al buscador — RxDart vs FxDart
description: Esperar a que el tecleo se calme antes de buscar — debounceTime sobre el stream de eventos vs la misma cadena debounce en la capa de eventos de fxdart 0.7.3.
heading: Aplicar debounce al buscador
order: 40
tier: 4
functions: fxEvents, debounce, map
domain: users
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Un usuario teclea <code>f</code>, <code>fx</code>, <code>fxd</code>
    en una ráfaga rápida, hace una pausa, y luego teclea
    <code>fxdart</code>. Busca solo cuando el tecleo haya estado en
    silencio 160&nbsp;ms — de modo que corren exactamente dos búsquedas
    (<code>fxd</code> y <code>fxdart</code>) — e imprime cada resultado.
    El calendario de pulsaciones está simulado en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ya no difieren. Este es un problema <em>push</em> en su forma más
    pura — lo interesante no son los valores sino <strong>cuándo dejan
    de llegar</strong> — y ambos paneles lo dicen ahora de la misma
    manera: aplicar debounce al stream de eventos con 160&nbsp;ms,
    buscar cada consulta superviviente, recoger. RxDart lo escribe
    <code>debounceTime</code>; fxdart&nbsp;0.7.3 lo escribe
    <code>fxEvents(...).debounce(...)</code>. Operador por operador, las
    dos cadenas son equivalentes, hasta en el valor final vaciado al
    cerrar.
  </p>
  <p>
    Es deliberado: la capa de eventos de fxdart absorbió el enfoque Rx
    para el lado push. <code>fxEvents</code> es una cadena envoltorio
    fina sobre <code>Stream</code>s de Dart llanos — nunca una
    extensión, así que no colisiona con nada, rxdart incluido — que da a
    los operadores basados en tiempo un hogar que los pipelines pull con
    razón se negaron a ser. El catálogo de operadores de RxDart sigue
    siendo mucho más amplio; fxdart cubre los verbos push cotidianos y
    se detiene ahí. Y cuando las consultas con debounce deban alimentar
    trabajo tipado y dirigido por demanda — fetches concurrentes
    ordenados, manejo de errores tipado — <code>.pull()</code> es la
    puerta de vuelta al pipeline <code>FxAsync</code>.
  </p>
