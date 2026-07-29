---
slug: first-visit-merchants
title: Comercios en orden de primera visita — Dart vs FxDart
description: Deduplicación que preserva el orden — un bucle con conjunto de vistos en Dart nativo frente a map + uniq en FxDart.
heading: Comercios en orden de primera visita
order: 4
tier: 1
functions: map, uniq
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de un mes de transacciones, lista cada comercio
    <strong>una sola vez</strong>, en el orden en que fue
    <strong>visitado por primera vez</strong>: las visitas repetidas no
    deben desplazar un comercio más abajo en la lista. Los datos están en
    el código de abajo; las dos versiones deben imprimir la línea que
    aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La tentadora línea nativa es <code>toSet().toList()</code>, y hasta
    imprimiría lo correcto, porque el conjunto por defecto de Dart resulta
    estar ordenado por inserción. Pero el contrato de
    <code>Iterable.toSet</code> no promete orden alguno, así que un código
    cuyo <em>requisito</em> es el orden de primera visita no debería
    apoyarse en él; la versión nativa honesta es un bucle con un conjunto
    de vistos, dos colecciones y un <code>if</code>. El <code>uniq</code> de
    FxDart hace que la garantía forme parte del nombre: conserva de forma
    perezosa la primera aparición de cada elemento, por contrato, en un
    único paso de la cadena después de <code>map</code>.
  </p>
