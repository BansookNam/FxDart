---
slug: valid-emails
title: Los 5 primeros correos válidos, normalizados — Dart vs FxDart
description: Recortar, pasar a minúsculas, validar y tomar cinco — map/where/take en Dart nativo frente a map + filter + take en FxDart. Aquí Dart nativo es igual de limpio.
heading: Los 5 primeros correos válidos, normalizados
order: 19
tier: 2
functions: map, filter, take
alsoLink: fx, groupBy, scan, zip, concurrent
domain: users
verdict: native
async: false
---
  <h2>Requisito</h2>
  <p>
    Los datos de registro llegan sucios: espacios sobrantes, mayúsculas y
    minúsculas mezcladas y un par de cadenas que ni siquiera son correos.
    Normaliza cada entrada (recorta, pasa a minúsculas), quédate solo con los
    correos plausibles (que contengan <code>@</code> y un punto) e imprime
    los <strong>cinco primeros</strong>. Los datos están en el código de
    abajo; ambas versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    No difieren, y de eso se trata. <code>map</code>, <code>where</code> y
    <code>take</code> vienen de serie en todo <code>Iterable</code> de Dart,
    son perezosos, y las dos versiones son el mismo pipeline salvo que
    <code>where</code> se llama <code>filter</code>. Para una cadena corta de
    normalizar-validar-truncar como esta, Dart nativo es igual de claro —
    recurre a él sin dudarlo. FxDart se gana su sitio cuando el pipeline
    necesita vocabulario del que Dart carece (<code>groupBy</code>,
    <code>scan</code>, <code>zip</code>, <code>concurrent</code>…) o cuando
    el resto del archivo ya encadena con <code>fx</code>; añadir una
    dependencia solo por este fragmento no aporta nada.
  </p>
