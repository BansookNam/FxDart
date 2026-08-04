---
slug: successes-and-failures
title: Separar éxitos de fallos — RxDart vs FxDart
description: Siete validaciones async, dos fallan — un try/catch por elemento que alimenta una partición tipada vs streams internos que devuelven el canal de errores a los datos.
heading: Separar éxitos de fallos
order: 26
tier: 3
functions: fx, toAsync, map, partition
domain: orders
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Siete pedidos de la importación 2026-08 pasan por una validación
    async que lanza para dos de ellos (una dirección de envío ausente, un
    SKU desconocido). Conserva <strong>ambos</strong> desenlaces: imprime
    una línea <code>ok:</code> por pedido válido, y luego el conteo de
    fallos. Los datos están en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Un stream tiene dos canales — datos y error — y el canal de errores
    tiene semántica de stream completo: una sola validación lanzada
    mataría el pipeline con cinco pedidos aún sin procesar. Así que el
    lado RxDart no puede simplemente <code>asyncMap(validate)</code>;
    envuelve <em>cada</em> validación en su propio stream interno
    (<code>Rx.fromCallable</code>), captura en ese canal de errores
    interno con <code>onErrorReturnWith</code>, y re-codifica el fallo
    como un valor de datos antes de fusionar de vuelta. La recuperación
    funciona, pero es fontanería de canales: el error tuvo que abandonar
    la vía de datos solo para ser escoltado de regreso.
  </p>
  <p>
    El lado FxDart nunca pone los fallos en un canal aparte. Un try/catch
    dentro de <code>map</code> convierte cada desenlace en un registro
    llano — <code>(id, error?)</code> — y a partir de ahí
    <code>partition</code> es una división por predicado corriente. Esta
    es la postura general del modelo pull ante los errores: son
    <em>valores</em> que fluyen por el mismo pipeline tipado que todo lo
    demás, así que mantener juntos éxitos y fallos no cuesta nada. Cuando
    los desenlaces son parte del resultado y no una interrupción, el
    modelo sin canal de errores privilegiado tiene menos que deshacer.
  </p>
