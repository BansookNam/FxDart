---
slug: rate-limited-import
title: Importación por lotes con límite de tasa — Dart vs FxDart
description: Importa 9 transacciones en lotes de 3, un lote cada vez, con un total acumulado — chunk + concurrent(1) + scan frente a un bucle secuencial.
heading: Importación por lotes con límite de tasa
order: 46
tier: 4
functions: chunk, toAsync, map, concurrent, delay, scan, drop, sumBy
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Envía nueve transacciones del libro de cuentas (están en el código de
    abajo) a un endpoint de importación que acepta <strong>lotes de tres,
    una llamada cada vez</strong>: estrictamente secuencial, nunca
    solapadas. Después de cada lote, registra su tamaño, su importe y el
    total acumulado importado hasta el momento; imprime los resúmenes de
    lote en orden y luego demuestra que se respetó el límite de tasa
    mediante el contador de máximo en vuelo (debe marcar 1).
  </p>
  <p>
    En FxDart la política entera es la cadena: <code>chunk(3)</code> fija
    el tamaño del lote, <code>concurrent(1)</code> fija el ritmo y
    <code>scan</code> hila el total acumulado a través de las
    confirmaciones (<code>drop(1)</code> descarta el valor inicial del
    scan). El propio endpoint simula la latencia con <code>delay</code> y
    suma su lote con <code>sumBy</code>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Seamos justos: una importación estrictamente secuencial es la única
    política de concurrencia que un simple bucle <code>for</code> maneja
    con elegancia, y la versión nativa se lee bien —<code>slices</code> de
    <code>package:collection</code> hasta cubre el troceado en lotes—. El
    total acumulado, en cambio, ya es estado mutable hilado a mano
    (<code>running += amount</code> junto a <code>n++</code>), mientras que
    <code>scan</code> lo convierte en un paso declarado. Y la sencillez del
    bucle es un callejón sin salida: el día que el endpoint permita dos
    lotes concurrentes, la versión con FxDart cambia <code>1</code> por
    <code>2</code>, mientras que el bucle se convierte en el pool de
    workers de los otros ejemplos asíncronos. La cadena enuncia la
    política; el bucle la codifica.
  </p>
