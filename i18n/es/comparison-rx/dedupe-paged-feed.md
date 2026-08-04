---
slug: dedupe-paged-feed
title: Deduplica un feed paginado por id — RxDart vs FxDart
description: Aplanar tres páginas que se solapan y conservar cada id de producto una vez, en orden de llegada — expand más distinctUnique frente a flatMap más uniqBy.
heading: Deduplica un feed paginado por id
order: 23
tier: 2
functions: fx, flatMap, uniqBy, map
domain: orders
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Un feed de productos llega en tres páginas cuyos bordes se solapan,
    así que algunos artículos aparecen en dos páginas. Aplana las páginas
    e imprime cada artículo exactamente una vez — gana la primera
    aparición, se conserva el orden de llegada — con su id numérico como
    clave. Las páginas están en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El dato interesante es dónde están los duplicados. Los bordes de las
    páginas se solapan, así que un id repetido llega en una <em>página
    distinta</em> — nunca junto a su primera aparición una vez aplanadas
    las páginas. Ese es exactamente el trabajo que el
    <code>Stream.distinct</code> corriente hace mal en silencio: es solo
    adyacente, así que en este feed dejaría pasar de largo todas las
    repeticiones. La deduplicación aquí necesita memoria de todo el feed,
    mientras que el aplanado en sí es fluido en ambos modelos —
    <code>expand</code> en el stream, <code>flatMap</code> en la cadena
    pull.
  </p>
  <p>
    Como en la pareja de los visitantes únicos, la deduplicación global es
    <code>distinctUnique</code> contra <code>uniqBy</code> — una pareja
    <code>equals</code>/<code>hashCode</code> frente a una sola función de
    clave — y la división de nombres adyacente-contra-global es la que
    recorre la página de los cambios de estado. Ambos lados mantienen el
    mismo conjunto de claves vistas y preservan el orden de primera
    llegada, así que el veredicto es un empate — la versión pull
    simplemente se mantiene síncrona porque las páginas están en una lista
    local.
  </p>
