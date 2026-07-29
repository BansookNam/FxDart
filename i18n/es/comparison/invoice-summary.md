---
slug: invoice-summary
title: De líneas de pedido a resumen de factura — Dart vs FxDart
description: Convierte las líneas de un pedido en totales por categoría más un total general — dos modismos de bucle y fold en Dart nativo frente a groupBy + sumBy + sortBy en FxDart.
heading: De líneas de pedido a resumen de factura
order: 27
tier: 3
functions: map, groupBy, sumBy, sortBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Cada línea de un pedido tiene un producto, una categoría, una cantidad
    y un precio unitario. Imprime el resumen de la factura: una línea por
    categoría con su total (cantidad × precio unitario, sumado),
    <strong>la categoría mayor primero</strong>, y después un total
    general. Los datos están en el código de abajo; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El mismo importe, <code>qty * unitPrice</code>, se suma dos veces —por
    categoría y en total— y las dos versiones tratan eso de forma distinta.
    Dart nativo lo deletrea con dos modismos que no se parecen en nada: un
    bucle <code>for</code> que muta un map para las categorías y luego un
    <code>fold</code> con un valor inicial explícito para el total general.
    FxDart dice «suma de un campo» igual las dos veces
    —<code>sumBy</code>— una por cada grupo de <code>groupBy</code> y otra
    sobre todos los elementos, con <code>sortBy</code> ordenando las filas.
    Cuando la factura gane una regla de descuento, un único vocabulario
    cambia en un solo sitio por pipeline; la versión nativa cambia el cuerpo
    de un bucle <em>y</em> un fold.
  </p>
