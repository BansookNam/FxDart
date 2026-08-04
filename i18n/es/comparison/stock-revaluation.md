---
slug: stock-revaluation
title: Revaluar el stock, tres consultas a la vez — Dart vs FxDart
description: Consultas de precios en vivo con respaldo — un pool de workers y pares hechos a mano en Dart nativo frente a attach + concurrent + countWhere en FxDart.
heading: Revaluar el stock, tres consultas a la vez
order: 48
tier: 4
functions: toAsync, attach, concurrent, map, sumBy, countWhere
domain: orders
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un almacén guarda artículos de stock, cada uno con un SKU, una
    cantidad disponible y un precio de libro. Refresca cada precio
    unitario desde un servicio de precios — <strong>como mucho tres
    consultas en vuelo</strong> —, recurriendo al precio de libro para los
    SKU que el servicio no conoce. Imprime el valor total revaluado del
    stock y cuántos artículos usaron el respaldo. El servicio se simula en
    el código de abajo con un retardo fijo; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Aquí se apilan dos partes difíciles. La consulta no puede perder su
    artículo — <code>attach</code> mantiene cada línea de stock junto al
    precio que devolvió el servicio (o <code>null</code>), que es lo que
    convierte el respaldo
    <code>r.$2&nbsp;??&nbsp;r.$1.bookPrice</code> en una sola línea. Y el
    fan-out debe estar acotado — <code>concurrent(3)</code> es el límite
    como operador, ya que <code>attach</code> viaja sobre la misma
    maquinaria segura en paralelo que <code>map</code>. Los recuentos caen
    solos del vocabulario: <code>sumBy</code> para el total,
    <code>countWhere</code> para el conteo de respaldos.
  </p>
  <p>
    La versión nativa tiene que construirlo todo: un pool de workers con
    cursor compartido para el límite, registros
    <code>(artículo, precio)</code> hechos a mano para que la entrada
    sobreviva el salto async, huecos de resultado predimensionados para
    conservar el orden, y una pasada de <code>where(…).length</code> para
    el conteo. Nada de eso es difícil — todo es ceremonia que entierra la
    tarea de cuatro pasos.
  </p>
