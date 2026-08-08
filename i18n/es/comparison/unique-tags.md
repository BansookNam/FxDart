---
slug: unique-tags
title: Todas las etiquetas de las entradas, ordenadas — Dart vs FxDart
description: Aplanar las etiquetas de las entradas en una sola lista ordenada y sin repetidos — expand + toSet + sort en Dart nativo frente a flatMap + uniq + sort en FxDart. Un empate en la página, 1,5× en el reloj.
heading: Todas las etiquetas de las entradas, ordenadas
order: 12
tier: 2
functions: flatMap, uniq, sort
domain: general
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Cada entrada del blog lleva una lista de etiquetas. Construye el índice
    de etiquetas del sitio: aplana las etiquetas de todas las entradas en una
    sola secuencia, elimina los duplicados, ordénalas alfabéticamente e
    imprímelas en una única línea separada por comas. Los datos están en el
    código de abajo; ambas versiones deben imprimir la línea que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Sobre el papel, apenas difieren. <code>expand</code> es el
    <code>flatMap</code> de Dart, <code>toSet()</code> elimina duplicados y
    una cascada <code>..sort()</code> remata el trabajo — esa cadena es Dart
    honesto e idiomático, y no tiene nada de malo. FxDart deletrea esos
    mismos tres pasos como eslabones con nombre de una cadena
    (<code>flatMap → uniq → sort</code>), lo que se lee un poco más como el
    requisito y deja explícito que <code>uniq</code> preserva el orden, en
    lugar de que sea un efecto secundario de haber elegido un
    <code>Set</code>. Como código, esto es un empate.
  </p>
  <p>
    El reloj no empata. Las barras de Benchmark de abajo ponen a FxDart a
    <strong>1,47× la velocidad</strong> de la cadena nativa con un millón de
    entradas — 73,5 ms frente a 108,0 ms — y la proporción se mantiene hasta
    abajo (1,36× con N=10.000, 1,29× con N=100; esas dos escalas siguen
    llevando la insignia <em>misma velocidad</em> sólo porque la diferencia
    absoluta ahí queda por debajo del umbral de percepción de 0,6 ms que usa
    el sitio). Ambos lados hacen exactamente el mismo trabajo: tres millones
    de cadenas de etiqueta tiradas a través de un aplanador, metidas en un
    conjunto hash que retiene 500 valores distintos, y una ordenación de 500
    elementos. El algoritmo no cambia en nada.
  </p>
  <p>
    Toda la diferencia vive en un campo del <code>ExpandIterator</code> de
    <code>dart:core</code>. Inicializa su ranura de iterador interno con un
    centinela <code>const EmptyIterator&lt;Never&gt;()</code> para poder
    aplazar la primera llamada al callback, y eso hace que la línea caliente
    — <code>_currentExpansion!.moveNext()</code>, ejecutada una vez por cada
    etiqueta emitida — vea <em>dos</em> clases receptoras a lo largo del
    bucle. Con eso basta para que AOT no pueda incorporar (inline) el
    iterador interno de <code>List</code>, así que los tres millones de
    avances internos se convierten en llamadas indirectas. El
    <code>flatMap</code> de FxDart guarda un simple
    <code>Iterator&lt;B&gt;?</code> que sólo contiene el iterador interno
    real y usa <code>null</code> para «todavía no hay ninguno abierto», de
    modo que ese mismo punto de llamada se mantiene monomórfico y se
    incorpora.
  </p>
  <p>
    No es una conjetura. Cambiando <em>sólo</em> el aplanador — el
    <code>flatMap</code> de FxDart alimentando el propio
    <code>toSet().toList()..sort()</code> nativo — ya se baja a 78 ms;
    cambiando sólo el otro extremo, el <code>expand</code> del núcleo hacia
    <code>uniq</code> y <code>sort</code>, se queda en 108 ms. Copiando
    <code>ExpandIterator</code> a mano dentro del benchmark y tocando nada
    más que ese centinela (iterador vacío → <code>null</code>) se pasa de 105
    ms a 77 ms por sí solo; la otra diferencia de forma, el
    <code>_current</code> anulable del núcleo leído mediante un cast, no
    cuesta nada medible. Cada variante se compiló con AOT como binario
    propio, porque meterlas todas en un mismo programa vuelve polimórfico
    cada punto de llamada a <code>moveNext</code> y borra justo el efecto que
    se quiere medir.
  </p>
  <p>
    Dos matices que conviene retener. Esto es un detalle de implementación
    del SDK, no una ley: el día que <code>ExpandIterator</code> se deshaga de
    ese centinela, <code>expand</code> igualará a FxDart y esta página
    volverá a ser un empate en ambas columnas. Y un bucle <code>for</code>
    anidado escrito a mano que añade directamente a un <code>Set</code> gana
    a los dos, con 43 ms — abandonar del todo el protocolo de iteradores
    sigue siendo lo más rápido que se puede hacer aquí. Lo que la medición
    descarta es la suposición de que recurrir a un pipeline con nombre te
    cuesta velocidad frente a la cadena idiomática del núcleo. Aquí te la da.
  </p>
