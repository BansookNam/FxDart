---
slug: clean-nullable-readings
title: Descarta los null, conserva los valores — RxDart vs FxDart
description: Limpiar un feed de sensor con nulos y formatear los supervivientes — whereNotNull es compact con otro nombre, y ambos estrechan double? a double estáticamente.
heading: Descarta los null, conserva los valores
order: 8
tier: 1
functions: fx, compact, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Un monitor de batería produjo nueve muestras de voltaje, tres de las
    cuales el sensor perdió (<code>null</code>). Descarta los fallos,
    imprime cada muestra superviviente formateada a un decimal y luego
    informa de cuántas se perdieron. Los datos están en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    <code>whereNotNull</code> <em>es</em> <code>compact</code> — el mismo
    operador vistiendo la convención de nombres de cada biblioteca. Ambos
    hacen lo que importa más allá de filtrar: <strong>estrechan el tipo
    estático</strong>, convirtiendo un tipo de elemento
    <code>double?</code> en <code>double</code>, de modo que la llamada a
    <code>toStringAsFixed</code> aguas abajo no necesita comprobaciones de
    null ni <code>!</code>. Filtrar y promover en una sola palabra, en
    ambos lados.
  </p>
  <p>
    Así que el veredicto es un empate en vocabulario — y el resto honesto
    es solo el modelo de entrega. La versión stream eleva a un
    <code>Stream</code> una lista que ya tiene en la mano y espera con
    await a recuperar la colección; la versión pull termina antes de que
    el primer <code>await</code> de la versión stream hubiera llegado a
    ejecutarse. En una lista fija de nueve elementos esa sobrecarga es lo
    bastante pequeña como para encogerse de hombros — exactamente la
    diferencia entre este ejemplo y la agregación que carga con el
    veredicto en <em>Suma los importes pares válidos</em>: aquí el punto
    es que las dos bibliotecas están de acuerdo, hasta en la promoción de
    tipos.
  </p>
