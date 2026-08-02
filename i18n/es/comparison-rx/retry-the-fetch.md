---
slug: retry-the-fetch
title: Reintentar el fetch inestable — RxDart vs FxDart
description: Un fetch que falla dos veces y luego acierta — Rx.retry re-suscribe una fábrica de streams, el retry de fxdart re-ejecuta un Future, ambos en una llamada.
heading: Reintentar el fetch inestable
order: 27
tier: 3
functions: fx, retry
domain: general
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    El endpoint del manifiesto corta la conexión exactamente dos veces
    antes de servir su payload. Reintenta hasta que tenga éxito, con un
    presupuesto de tres intentos en total, y luego imprime el payload y
    cuántos intentos hicieron falta. La inyección del fallo es
    determinista y está en el código; las dos versiones deben imprimir las
    líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas nada — esto es una sola llamada en cada lado, y ese es el
    sentido del par. La diferencia está en qué <em>significa</em> «volver
    a intentarlo» en cada modelo. En RxDart un stream que ha errado está
    muerto, así que <code>Rx.retry</code> toma una <strong>fábrica</strong>
    y la re-suscribe: reintentar es volver a escuchar, y el argumento de
    conteo es el número de <em>reintentos</em> después del primer intento
    (aquí <code>2</code>, para tres intentos). En FxDart la cosa inestable
    es una función que devuelve un <code>Future</code>, así que
    <code>retry</code> simplemente la llama otra vez —
    <code>attempts</code> es el presupuesto total (<code>3</code>), y el
    último error se relanza con su stack trace original cuando el
    presupuesto se agota.
  </p>
  <p>
    Un empate genuino. Las formas solo divergen cuando la cosa reintentada
    crece: si se convierte en un pipeline de varios valores, RxDart
    mantiene el mismo idioma de fábrica, mientras que FxDart envuelve el
    terminal (<code>retry(3, () => fxAsync(…).toList())</code>) o pasa a
    reintentos por elemento — un par con entidad propia, dos ejemplos más
    adelante.
  </p>
