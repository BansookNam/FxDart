---
slug: upload-batches
title: Sube en lotes de 4 — RxDart vs FxDart
description: Diez archivos pendientes, como mucho cuatro por petición — bufferCount(4) en el stream frente a chunk(4) en la cadena pull, con el último lote corto en ambos lados.
heading: Sube en lotes de 4
order: 11
tier: 2
functions: fx, chunk, map
domain: orders
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Hay diez archivos en cola para subir y la API acepta como mucho
    <strong>cuatro por petición</strong>. Agrupa la cola en lotes de 4 (el
    último queda corto) e imprime el tamaño y los ids de cada lote. Los
    datos están en el código; las dos versiones deben imprimir las líneas
    que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El loteo sin solapamiento es vocabulario básico en ambos modelos, y
    ambos lo dicen en una palabra: <code>bufferCount(4)</code> junta
    cuatro eventos antes de emitir una <code>List</code>,
    <code>chunk(4)</code> tira de cuatro valores a una <code>List</code>
    por demanda. Ambos vuelcan el lote final corto cuando la fuente se
    agota. El <code>map</code> que formatea cada lote es, a partir de ahí,
    idéntico carácter por carácter.
  </p>
  <p>
    Donde los modelos empezarían a divergir queda justo fuera del marco de
    este ejemplo. Un stream almacena porque los valores llegan según su
    propio calendario — <code>bufferCount</code> tiene además hermanos
    basados en tiempo (<code>bufferTime</code>) que un pipeline pull
    deliberadamente no ofrece, porque «lo que llegó en el último segundo»
    no significa nada cuando el consumidor controla la llegada. Una cadena
    pull trocea porque el <em>consumidor</em> quiere demanda de cuatro en
    cuatro — que es también la razón de que <code>chunk</code> componga
    directamente con la concurrencia aguas abajo (enviar cada lote
    mientras se arma el siguiente). Para una cola fija de diez, ninguna de
    las dos ventajas se ejercita: empate.
  </p>
