---
slug: unique-visitors
title: Visitantes únicos, conservando la primera visita — RxDart vs FxDart
description: Deduplicar un registro de visitas a lo largo de todo el feed, conservando la primera visita de cada usuario — distinctUnique con equals+hashCode frente a uniqBy con una sola función de clave.
heading: Visitantes únicos, conservando la primera visita
order: 5
tier: 1
functions: fx, uniqBy, map
domain: users
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    El registro de visitas de hoy contiene ocho visitas de cuatro cuentas.
    Conserva solo la <strong>primera</strong> visita de cada usuario —
    deduplicando a lo largo de todo el registro, no solo entre entradas
    adyacentes — e imprime quiénes son, cuándo llegaron por primera vez y
    el recuento de únicos. Los datos están en el código; las dos versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Este es uno de los mejores emparejamientos de RxDart con un operador
    de FxDart. El <code>Stream.distinct</code> corriente solo compara
    eventos <em>adyacentes</em> (el <code>uniqAdjacent</code> de FxDart es
    la misma idea), así que RxDart añade <code>distinctUnique</code>:
    deduplicación a lo largo de todo el stream, conservando la primera
    aparición — exactamente el contrato de <code>uniqBy</code>. Ambos
    mantienen un conjunto de vistos durante la vida del stream, ambos
    preservan el orden de llegada, y las revisitas de ana a las 09:40 y
    las 11:48 desaparecen de forma idéntica en ambos lados.
  </p>
  <p>
    La diferencia restante es ergonómica, no semántica. «Mismo visitante»
    es una función de clave para <code>uniqBy</code> —
    <code>(v) =&gt; v.user</code> — mientras que
    <code>distinctUnique</code> pide una pareja acompasada de
    <code>equals</code> + <code>hashCode</code>, dos closures que deben
    estar de acuerdo entre sí. Eso es una molestia leve, no un hueco de
    modelo, y el main asíncrono es la sobrecarga de stream habitual sobre
    datos fijos. Veredicto: empate — el operador de deduplicación global
    existe en ambos lados y se comporta igual.
  </p>
