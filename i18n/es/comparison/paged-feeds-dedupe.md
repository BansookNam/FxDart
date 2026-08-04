---
slug: paged-feeds-dedupe
title: Dos feeds paginados, concatenados y deduplicados — Dart vs FxDart
description: Vacía un almacén de logs primario, luego su réplica, deduplica por id y para en 8 — concat + uniqBy + take siguen siendo perezosos, frente a bucles anidados con un conjunto de vistos.
heading: Dos feeds paginados, concatenados y deduplicados
order: 41
tier: 4
functions: range, toAsync, flatMap, concat, uniqBy, take
domain: logs
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Los eventos de log viven en dos almacenes paginados: uno primario y
    una réplica cuyas páginas se solapan con las del primario (algunos
    eventos se enviaron a ambos). Trae páginas de tres (llamadas
    simuladas, datos fijos en el código de abajo), lee <em>primero por
    completo</em> el primario y después la réplica, descarta los eventos
    ya vistos (por id) y para tras los primeros <strong>ocho eventos
    únicos</strong>. Informa de cuántas de las cinco páginas se llegaron a
    pedir realmente.
  </p>
  <p>
    Para ser precisos sobre qué es el <code>concat</code> de FxDart: un
    añadido <strong>secuencial</strong>, no una mezcla — la réplica no se
    toca hasta que el primario se ha agotado. Aquí esa es la herramienta
    correcta, porque la tarea quiere que ganen los eventos del primario.
    Cada almacén se convierte en una secuencia asíncrona con
    <code>range</code> + <code>flatMap</code> (número de página → página
    de eventos), y <code>uniqBy</code> + <code>take(8)</code> rematan el
    trabajo. Como la cadena está basada en pull, que <code>take</code> se
    detenga detiene también la paginación: la última página de la réplica
    no se pide nunca.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La versión nativa son tres bucles anidados con un conjunto
    <code>seen</code> y un <code>break outer;</code> etiquetado — cada
    pieza (paginación, orden, deduplicación, salida temprana) tejida a
    mano dentro del flujo de control, y la salida temprana es la parte que
    mantiene el recuento de páginas en cuatro. Funciona, pero cada
    política vive en una cláusula de guarda en lugar de en un nombre. La
    cadena de FxDart le da a cada política su propia palabra —
    <code>concat</code> para la secuenciación, <code>uniqBy</code> para la
    deduplicación, <code>take</code> para el presupuesto — y la pereza que
    se salta la quinta página es el comportamiento por defecto del
    pipeline, no un salto cuidadosamente colocado.
  </p>
