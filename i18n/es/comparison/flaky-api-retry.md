---
slug: flaky-api-retry
title: Sondear una API inestable hasta el primer éxito — Dart vs FxDart
description: Reintentar hasta que esté listo, como pipeline perezoso — range + toAsync + map + dropWhile + head frente a un bucle de sondeo imperativo con un break.
heading: Sondear una API inestable hasta el primer éxito
order: 42
tier: 4
functions: range, toAsync, map, peek, dropWhile, head
domain: general
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    El endpoint de estado de un trabajo de exportación es inestable de
    forma determinista: los cuatro primeros sondeos responden
    <code>pending</code> y el quinto responde <code>ready</code>. Sondéalo
    hasta diez veces, guarda un registro de cada sondeo, detente en el
    primer éxito e informa de qué intento ganó, además de cuántos sondeos
    se hicieron realmente. Sin aleatoriedad: el número de fallos está
    fijado en el código de abajo, así que las dos versiones imprimen lo
    mismo en cada ejecución.
  </p>
  <p>
    La versión con FxDart escribe el reintento como datos:
    <code>range(1, 11)</code> es el calendario de sondeos,
    <code>map</code> es el transporte, <code>peek</code> anota el registro,
    y <code>dropWhile</code> + <code>head</code> son la política de éxito.
    Como la cadena es perezosa y se tira de ella valor a valor,
    <code>head</code> detiene el sondeo: solo llegan a hacerse cinco
    peticiones.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Con honestidad: el bucle <code>for</code> nativo con un
    <code>break</code> es corto, y nadie diría que está mal. La diferencia
    está en dónde vive cada pieza. En el bucle, el presupuesto de intentos,
    el registro y la prueba de éxito quedan enredados en el flujo de
    control: cambia uno y tienes que releer el cuerpo entero. En el
    pipeline, cada preocupación es su propio paso con nombre, así que
    cambiar la política (primer éxito → tercer éxito, añadir una
    transformación, ampliar el presupuesto) significa editar una línea. Y la
    garantía de pereza —ningún sondeo después del ganador— es estructural en
    FxDart, mientras que en el bucle depende de que el <code>break</code>
    esté en el sitio correcto.
  </p>
