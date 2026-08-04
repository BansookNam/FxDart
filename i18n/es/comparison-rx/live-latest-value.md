---
slug: live-latest-value
title: Un valor actual en vivo para lectores tardíos — RxDart vs FxDart
description: Un panel que se conecta tarde aún recibe la temperatura actual al instante — BehaviorSubject y LiveValue reemiten ambos el último valor, y luego transmiten en vivo.
heading: Un valor actual en vivo para lectores tardíos
order: 39
tier: 4
functions: liveValue, fxEvents
domain: sensors
verdict: tie
async: true
noBenchmark: timing
---
  <h2>Requisito</h2>
  <p>
    Un feed de temperatura empuja actualizaciones con un calendario fijo.
    Un panel se conecta solo después de que las tres primeras
    actualizaciones ya hayan pasado — aun así debe mostrar el valor
    <strong>actual</strong> de inmediato (19.1&nbsp;°C, el más reciente
    en el momento de unirse), y luego cada actualización posterior. El
    calendario está simulado en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    No difieren. «El último valor, reemitido a quien aparezca» es
    <em>estado compartido y multicast</em>, y fxdart también tiene un
    objeto dedicado para ello: <code>LiveValue</code>
    es <code>BehaviorSubject</code> reducido a su comportamiento
    definitorio — un sumidero en el que el sensor escribe, un
    <code>.value</code> legible, y un feed donde un suscriptor tardío
    recibe primero el valor más reciente, y luego las actualizaciones en
    vivo. Ambos paneles son «añadir actualizaciones, suscribirse tarde,
    recoger» — sin variable cacheada a mano y sin oyente extra de caché.
  </p>
  <p>
    Esta es la capa de eventos de fxdart absorbiendo el enfoque Rx
    para el lado push: <code>LiveValue.live</code> devuelve una cadena
    <code>fxEvents</code> — un envoltorio fino sobre un
    <code>Stream</code> broadcast llano, así que no colisiona con nada,
    rxdart incluido — y <code>.pull()</code> cruza al pipeline pull
    tipado cuando el procesamiento por valor crece. La familia de
    subjects y el catálogo de operadores de RxDart siguen siendo mucho
    más amplios; para el último-valor-y-luego-en-vivo en sí, los paneles
    son equivalentes: empate.
  </p>
