---
slug: top-expenses
title: Los 3 gastos más grandes — Dart vs FxDart
description: Las tres transacciones más grandes del mes — sortedBy + take de package:collection frente a sortBy + take en FxDart.
heading: Los 3 gastos más grandes
order: 1
tier: 1
functions: sortBy, take
alsoLink: chunk, scan
domain: transactions
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    De un mes de gastos, imprime los <strong>tres más grandes</strong> —
    comercio e importe, de mayor a menor. Los datos están en el código de
    abajo; ambas versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas difieren — esto es un empate. Ambos lados ordenan por una clave
    negada para conseguir orden descendente y toman los tres primeros; el
    <code>sortedBy</code> de <code>package:collection</code> es igual de
    directo que el <code>sortBy</code> de FxDart (el <code>List.sort</code>
    del núcleo, por sí solo, mutaría en el sitio y necesitaría un
    comparador explícito, pero <code>collection</code> es una dependencia
    estándar). La única diferencia real está en dónde vive el vocabulario:
    un método de extensión de un paquete frente a un paso de una cadena
    que además ofrece <code>scan</code>, <code>chunk</code> y variantes
    asíncronas. Elige cualquiera de los dos con la conciencia tranquila.
  </p>
  <p>
    El listado empata; el reloj no. Con un millón de filas las barras de
    abajo tienen a FxDart unas 2,6× más rápido (200 ms frente a 521 ms), y
    no se debe a un big-O más listo — ambos copian la lista y ejecutan una
    mezcla estable O(n log n). La diferencia está en lo que cuesta una sola
    comparación.
  </p>
  <p>
    El <code>sortedBy</code> nativo es el <code>mergeSortBy</code> de
    collection: ordena las <em>filas</em> y llama al extractor de clave
    <em>dentro de cada comparación</em>. Un millón de filas son unas
    veinte millones de llamadas a <code>(t) => -t.amount</code>. El tipo
    de clave es un <code>K extends Comparable</code> genérico — aquí
    <code>num</code> — así que cada una de esas claves es un
    <code>double</code> encajonado en el montículo comparado por un
    <code>compareTo</code> virtual.
  </p>
  <p>
    El <code>sortBy</code> de FxDart extrae primero. Un recorrido de la
    lista escribe cada clave en un <code>Float64List</code> (vio que
    todas eran <code>double</code>). Luego mezcla las claves y las filas
    <em>juntas</em>, en orden: cada comparación son dos dobles de máquina
    de un array tipado, con una comparación de la VM en estos datos (los
    importes son positivos finitos ordinarios, así que no hay NaN ni
    <code>-0.0</code> que fuerce el camino más lento de
    <code>compareTo</code>). Una extracción por fila, sin encajonar, sin
    despacho y sin perseguir claves por un índice al azar. Un
    <code>sortBy</code> anterior decoraba ordenando una lista de índices
    con <code>List.sort</code>; eso ya no está. La mezcla es estable por
    construcción — las claves iguales conservan su orden de entrada en
    ambos lados ahora.
  </p>
  <p>
    El límite honesto: cuando las claves no son uniformemente
    <code>double</code>, <code>int</code> o <code>String</code>,
    <code>sortBy</code> recae en el comparador genérico y la ventaja
    desaparece. La memoria con un millón de filas está cerca (unos
    123 MB frente a 130 MB) — ambos retienen la copia de filas más un
    búfer auxiliar. Aquí los importes son todos distintos, así que la
    estabilidad no se ve en las tres líneas impresas.
  </p>
