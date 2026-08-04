---
slug: tee-the-pipeline
title: Una fuente, dos lectores independientes — RxDart vs FxDart
description: Total y máximo de una fuente con efectos sin ejecutarla dos veces — un stream conectable vs fork compartiendo una sola pasada con buffer.
heading: Una fuente, dos lectores independientes
order: 48
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
    la misma idea — compartir una sola pasada. RxDart hace el stream
    <em>conectable</em>: <code>publish()</code> difiere la fuente, ambas
    reducciones se suscriben, y <code>connect()</code> arranca la única
    suscripción que las alimenta. El <code>fork</code> de FxDart
    ramifica una sola iteración con buffer: cada fork del mismo objeto
    iterable es un cursor independiente sobre un buffer compartido, así
    que el cuerpo del generador corre una vez sin importar cuántos
    lectores tiren de él.
  </p>
  <p>
    Las diferencias son textura, no capacidad. La versión rx es sensible
    al orden — los lectores deben engancharse <em>antes</em> de
    <code>connect()</code>, y un rezagado se pierde eventos; eso es push:
    la entrega ocurre estés listo o no. La versión fx es sensible a la
    identidad — debes hacer fork del <em>mismo objeto</em>, y un fork que
    se rezaga simplemente reproduce el buffer a su propio ritmo; eso es
    pull: los valores esperan a la demanda. El coste es memoria: el
    buffer compartido retiene cada valor hasta que el fork más lento lo
    haya consumido, así que un lector muy rezagado mantiene viva la
    pasada entera, donde el rezagado de rx simplemente se la habría
    perdido. Cualquiera de las dos es una buena respuesta a «hacer un tee
    del pipeline», lo que convierte esto en un empate — elige la que
    encaje con el modelo en el que ya vive el resto de tu código.
  </p>
