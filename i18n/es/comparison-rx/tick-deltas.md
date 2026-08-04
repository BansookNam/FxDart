---
slug: tick-deltas
title: Deltas entre ticks — RxDart vs FxDart
description: Cada tick de precio junto a su predecesor — pairwise en ambas bibliotecas, parejas como listas en el lado stream, records tipados en el lado pull.
heading: Deltas entre ticks
order: 19
tier: 2
functions: fx, pairwise, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de siete ticks de precio, imprime los seis
    <strong>deltas</strong>: cada tick junto a su predecesor con el cambio
    con signo a dos decimales (un tick plano imprime <code>+0.00</code>).
    Los datos están en el código; las dos versiones deben imprimir las
    líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    No difieren, por diseño: <code>pairwise</code> es uno de los
    operadores que FxDart portó <em>desde</em> Rx, porque «cada valor con
    el anterior» es igual de natural tanto si los valores se empujan como
    si se tira de ellos. Ambos lados guardan un valor de estado, no emiten
    nada para el primer tick y producen n&nbsp;−&nbsp;1 parejas. El
    veredicto es un empate y la parte interesante es la pequeña diferencia
    de tipado en qué es una «pareja».
  </p>
  <p>
    El <code>pairwise</code> de RxDart emite una
    <code>List&lt;double&gt;</code> de dos elementos —
    <code>p.first</code> y <code>p.last</code> son honestos, pero el
    invariante de longitud 2 vive en la documentación, no en el tipo. El
    de FxDart emite un record de Dart <code>(double, double)</code>:
    <code>p.$1</code> y <code>p.$2</code> son los únicos campos que hay, y
    el compilador lo sabe. Eso es más un artefacto de la época del
    lenguaje que una diferencia de modelo — los records no existían cuando
    la API de RxDart se congeló — pero es representativo del hábito de la
    biblioteca pull de empujar los invariantes hacia los tipos. Sobre el
    modelo en sí: nada que elegir entre ellos aquí.
  </p>
