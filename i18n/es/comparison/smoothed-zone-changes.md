---
slug: smoothed-zone-changes
title: Cambios de zona suavizados — Dart vs FxDart
description: Media móvil, rachas de zona y alertas de transición — tres bucles con estado mutable en Dart puro vs windowed → uniqAdjacentBy → pairwise en FxDart.
heading: Cambios de zona suavizados
order: 43
tier: 4
functions: windowed, average, uniqAdjacent, pairwise, ifEmpty, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Un sensor de temperatura reporta doce lecturas crudas al día.
    Suavízalas con una <strong>media móvil de 3 lecturas</strong>,
    clasifica cada valor suavizado en una zona (<code>cool</code> &lt; 20°
    ≤ <code>ok</code> &lt; 25° ≤ <code>hot</code>) y reporta cada
    <strong>transición de zona</strong>: de qué zona sale, a cuál entra y
    los valores suavizados de ambos lados. Un día sin transiciones imprime
    una única línea <em>stable</em> en lugar de nada. Los datos de dos
    días de julio están en el código; ambas versiones deben imprimir las
    líneas mostradas bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Cada etapa de esta tarea necesita ver elementos <em>vecinos</em>, y
    ahí es exactamente donde a Dart puro se le acaba el vocabulario: no
    hay ventana deslizante, ni deduplicación adyacente, ni emparejamiento
    con el sucesor — ni en la biblioteca estándar ni en
    <code>package:collection</code> (<code>slices</code> divide sin
    solaparse). Así que la versión nativa son tres bucles con índice, cada
    uno cargando su propio estado mutable: una suma por ventana, una lista
    <code>runStarts</code> comparada contra su propia cola y una mirada
    atrás con <code>i&nbsp;-&nbsp;1</code> para las líneas de transición,
    más un parche final con <code>isEmpty</code> para el día estable.
  </p>
  <p>
    La cadena de FxDart enuncia las cinco etapas en el orden en que fluyen
    los datos: <code>windowed(3)</code> → <code>average</code> por
    ventana, <code>uniqAdjacentBy(zone)</code> conserva el primer valor
    suavizado de cada racha de zona, <code>pairwise</code> convierte los
    inicios de racha en transiciones (from,&nbsp;to), y
    <code>ifEmpty</code> aporta la línea del día estable dentro del
    pipeline en lugar de un if después. Cada fragmento se puede probar por
    separado y nada reimplementa límites de ventana. Estos cuatro
    operadores son nuevos en fxdart 0.7.2 — adaptaciones al modelo pull de
    la familia de ventanas de Rx.
  </p>
