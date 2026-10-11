---
slug: tee-the-pipeline
title: Una fuente, dos lectores independientes — RxDart vs FxDart
description: Total y máximo de una fuente con efectos secundarios sin ejecutarla dos veces — un stream conectable frente a dos pliegues que avanzan sobre el mismo elemento.
heading: Una fuente, dos lectores independientes
order: 50
tier: 4
functions: tee
domain: sensors
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Una fuente de lecturas debe alimentar <strong>dos</strong> cómputos
    independientes — el total y el pico — ejecutándose exactamente una
    vez. La fuente incrementa un contador cada vez que corre; imprime el
    total, el pico y el contador para demostrar la pasada única. Los
    datos están en el código; las dos versiones deben imprimir las líneas
    que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ambos modelos chocan aquí con el mismo muro: sus fuentes se reinician
    por consumidor. Escuchar dos veces un stream llano de suscripción
    única es un error; iterar dos veces un generador <code>sync*</code>
    lo ejecuta dos veces en silencio. Y ambas bibliotecas responden con
    la misma idea: compartir una sola pasada. RxDart hace el stream
    <em>conectable</em>: <code>publish()</code> difiere la fuente, ambas
    reducciones se suscriben, y <code>connect()</code> arranca la única
    suscripción que las alimenta. El <code>tee</code> de FxDart mantiene
    las dos reducciones en paso: cada elemento avanza el total y el pico
    antes de que se pida el siguiente, así que la pasada única nunca tiene
    que recordar nada.
  </p>
  <p>
    Ninguno de los dos usa buffer, y por la misma razón de fondo: cada
    lector ve cada elemento mientras es el actual. Eso es lo que compra
    <code>connect()</code> al obligar a los lectores a engancharse
    primero, y lo que compra <code>tee</code> al tomar a los lectores como
    pliegues: una semilla y un paso, en lugar de dos pipelines libres de
    avanzar por su cuenta. La restricción es el precio.
    <code>publish()</code> alimenta cualquier operador de stream que
    quieras suscribir; <code>tee</code> solo alimenta pliegues. Cuando los
    dos lectores son de verdad pipelines independientes, la respuesta de
    FxDart es <code>fxFork</code>: cada fork del mismo objeto iterable es
    un cursor sobre una sola pasada con buffer compartido, y ahí vuelve el
    buffer, que retiene cada valor hasta que el cursor más lento lo ha
    consumido. Así que es un empate en capacidad: la herramienta general
    cuesta memoria en ambos lados, y la especializada es gratis en ambos.
    Elige la que encaje con el modelo en el que ya vive el resto de tu
    código.
  </p>
