---
slug: audit-with-outcomes
title: Conserva valores Y fallos en la auditoría — RxDart vs FxDart
description: Parsear ocho líneas de configuración donde tres fallan, imprimiendo los valores y el recuento de fallos — errores colados de vuelta como datos frente a una partición sencilla.
heading: Conserva valores Y fallos en la auditoría
order: 22
tier: 2
functions: fx, map, partition
domain: logs
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Una auditoría de despliegue parsea ocho líneas de configuración
    <code>key=value</code>, tres de las cuales tienen valores imposibles
    de parsear. El informe necesita <em>ambas</em> mitades: imprime cada
    <code>key = value</code> parseado con éxito, y luego un recuento de
    los fallos. Las líneas están en el código; las dos versiones deben
    imprimir la salida que aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El modelo stream lleva los errores por un canal aparte, fuera de
    banda — y ese canal es terminal: una sola <code>FormatException</code>
    termina la suscripción entera, llevándose las cinco líneas buenas con
    ella. Para conservar valores <em>y</em> fallos, el lado RxDart tiene
    que darle a cada línea su propio stream interno
    (<code>Rx.fromCallable</code>) y convertir el error en datos antes de
    que pueda escapar — <code>onErrorReturn(null)</code> aquí, con
    <code>null</code> haciendo de «esta falló». Esa es la forma más ligera
    que el modelo permite para una función que lanza (la ruta más pesada
    de <code>materialize</code> reifica objetos de notificación
    completos), y existe solo para deshacer una decisión que el modelo
    tomó por ti: los errores nunca fueron valores desde el principio. (Los
    dos paneles comparten a propósito el mismo <code>parse</code> que
    lanza — con un parser que devolviera null ambos modelos podrían
    mantener los resultados como datos planos; el throw es la premisa, y
    lo que cada lado debe hacer al respecto es la comparación.)
  </p>
  <p>
    El lado pull nunca pone los fallos en un canal, para empezar. El mismo
    throw aterriza a un <code>try</code>/<code>catch</code> local de
    distancia de volver a ser un valor ordinario — un record anulable —
    así que el requisito completo es <code>map</code> y luego
    <code>partition</code>: una pasada, dos listas, ambas mitades igual de
    primera clase. Esta es la forma de la postura más amplia de FxDart
    sobre errores tipados (sus pipelines de <code>Either</code> son esta
    misma idea con tipos de error más ricos). Cuando los fallos son parte
    del informe y no un final excepcional, mantenerlos como datos gana —
    el veredicto se lo lleva FxDart.
  </p>
