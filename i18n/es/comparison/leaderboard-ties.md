---
slug: leaderboard-ties
title: Tabla de clasificación con puestos empatados — Dart vs FxDart
description: Clasifica jugadores de modo que las puntuaciones iguales compartan puesto — estado mutable rank/prevScore en Dart nativo frente a sortBy + groupBy + zipWithIndex en FxDart.
heading: Tabla de clasificación con puestos empatados
order: 26
tier: 3
functions: sortBy, groupBy, entries, zipWithIndex, flatMap
domain: users
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Imprime una tabla de clasificación a partir de las puntuaciones de seis
    jugadores, de mayor a menor, donde <strong>las puntuaciones iguales
    comparten puesto</strong>: ranking denso, así que dos jugadores con 87
    puntos son ambos el #2 y la siguiente puntuación por debajo es el #3.
    Los datos están en el código de abajo; las dos versiones deben imprimir
    las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Los empates obligan al bucle nativo a arrastrar dos piezas de estado
    mutable —el <code>rank</code> actual y la puntuación anterior— y la
    regla de empate vive dentro de un <code>if</code> cuya corrección
    compruebas reproduciendo el bucle en tu cabeza. La versión con FxDart
    declara la estructura en su lugar: <code>sortBy</code> descendente,
    <code>groupBy</code> por puntuación (un grupo por puesto), recorrer los
    grupos con <code>entries</code> + <code>zipWithIndex</code> (índice de
    grupo = puesto) y <code>flatMap</code> para devolver cada grupo a líneas
    de jugador. «Las puntuaciones iguales comparten puesto» deja de ser un
    comportamiento emergente del bucle y pasa a ser la forma del pipeline.
  </p>
