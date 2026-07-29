---
slug: first-over-limit
title: La primera lectura del sensor por encima del límite — Dart vs FxDart
description: Encuentra la primera temperatura por encima de un umbral — skipWhile + firstOrNull en Dart nativo frente a dropWhile + head en FxDart.
heading: La primera lectura del sensor por encima del límite
order: 6
tier: 1
functions: dropWhile, head
domain: sensors
verdict: native
async: false
---
  <h2>Requisito</h2>
  <p>
    Un sensor de temperatura registra una lectura cada diez minutos.
    Encuentra la <strong>primera</strong> lectura que supere el límite de
    <strong>75.0 C</strong> e imprime su hora y su valor —o una línea
    alternativa si ninguna lo cruzó—. Los datos están en el código de
    abajo; las dos versiones deben imprimir la línea que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    No difieren, y aquí Dart nativo es la elección honesta. El
    <code>skipWhile</code> del núcleo más <code>firstOrNull</code> (de
    <code>package:collection</code>) es una línea limpia y perezosa que dice
    exactamente lo que significa, con el mismo resultado nullable que hay
    que gestionar. El <code>dropWhile → head</code> de FxDart es la misma
    idea con los nombres de FxTS: merece la pena si el resto de tu archivo
    ya son cadenas de FxDart, pero nadie debería añadir una librería por
    esta línea. Cuando gana Dart nativo, lo decimos.
  </p>
