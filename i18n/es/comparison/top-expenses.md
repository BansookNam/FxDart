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
    El código empata; el reloj no. Las barras del Benchmark de abajo muestran
    a FxDart 1,5–1,8× más rápido con los mismos datos, y no se debe a un
    algoritmo más listo — ambos lados ejecutan una ordenación por comparación
    O(n log n). La diferencia está en lo que cuesta una sola comparación.
    <code>sortedBy</code> ordena los elementos y llama al extractor de clave
    <em>dentro</em> de cada comparación: con un millón de filas invoca
    <code>(t) => -t.amount</code> 19,6 millones de veces frente al millón de
    FxDart y, como su tipo de clave es un parámetro genérico, cada una de esas
    claves es un <code>double</code> encajonado en el montículo al que se
    llega por un <code>compareTo</code> virtual. FxDart decora en su lugar:
    extrae cada clave una vez, observa que todas salieron <code>double</code>,
    las copia a un <code>Float64List</code>, ordena una lista de índices y
    luego lee la permutación. A partir de ahí cada comparación son dos dobles
    de máquina sacados de un array tipado: sin asignación y sin despacho.
  </p>
  <p>
    De esos dos ahorros, el que rinde es el desencajonado. Medido en la
    máquina del benchmark con un millón de filas y compilado AOT: el mismo
    decorar-ordenar-desdecorar con claves <em>encajonadas</em> tarda 1051 ms —
    peor que los 522 ms de <code>sortedBy</code>, porque cada comparación
    sigue desreferenciando dos objetos del montículo y despachando un
    <code>compareTo</code> virtual, ahora con el acceso aleatorio que añade
    una permutación de índices — y cambiar solo el array de claves por un
    <code>Float64List</code> lo baja a 337 ms. Extraer la clave una sola vez
    es casi gratis por sí mismo; mantener las claves sin encajonar es toda la
    ventaja. Ese es también su límite honesto: cuando las claves no son
    uniformemente <code>double</code>, <code>int</code> o <code>String</code>,
    <code>sortBy</code> recae en el comparador genérico y la ventaja
    desaparece.
  </p>
  <p>
    Y la velocidad se paga, no se regala. Decorar mantiene vivos cuatro arrays
    en el pico — los elementos copiados, las claves, la permutación de índices
    y el resultado — mientras que la ordenación por mezcla necesita la copia
    más un búfer auxiliar de media talla, y por eso la barra de memoria se
    inclina al revés (183 MB frente a 126 MB con un millón de filas). El otro
    coste es la estabilidad: <code>sortedBy</code> es una mezcla estable,
    mientras que FxDart entrega sus índices a <code>List.sort</code>, que no
    lo es — las filas con claves iguales conservan su orden de entrada en el
    lado nativo y pueden salir barajadas en el lado FxDart. Aquí los importes
    son distintos y solo se imprimen tres filas, así que nada de esto se ve;
    en una tabla de clasificación con empates, sí se vería.
  </p>
