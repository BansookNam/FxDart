---
slug: live-latest-value
title: Un valor actual en vivo para lectores tardíos — RxDart vs FxDart
description: Un panel que se conecta tarde aún recibe la temperatura actual al instante — BehaviorSubject reemite el último valor; pull lo cachea a mano.
heading: Un valor actual en vivo para lectores tardíos
order: 47
tier: 4
functions: fx, streams
domain: sensors
verdict: rxdart
async: true
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
    «El último valor, reemitido a quien aparezca» no es un pipeline — es
    un pedazo de <em>estado compartido y multicast</em>, y RxDart tiene
    un objeto dedicado para ello. Un <code>BehaviorSubject</code> es a la
    vez el sumidero en el que el sensor escribe y un stream que cada
    suscriptor puede leer, y su comportamiento definitorio es exactamente
    este requisito: un oyente tardío recibe primero el valor más
    reciente, y luego el feed en vivo. El panel rx entero es «añadir
    actualizaciones, suscribirse tarde, recoger».
  </p>
  <p>
    FxDart omite deliberadamente cualquier cosa parecida a un subject —
    un pipeline pull es una cadena de demanda de un solo consumidor, no
    un centro de difusión. El panel FxDart tiene que <em>simular</em> el
    subject: un controller broadcast, un oyente escrito a mano que cachea
    el último valor en una variable, y un puente <code>fxStream</code>
    para el resto una vez que el lector tardío se une. Imprime las mismas
    líneas, pero cada pieza que el subject daba gratis (la caché, la
    reemisión al unirse, el ciclo de vida de la segunda suscripción) es
    ahora código manual que hay que mantener correcto. La decisión
    práctica: para estado multicast de último valor, usa RxDart — y
    tiende el puente hacia un pipeline FxDart tipado aguas abajo del
    subject cuando el procesamiento por valor crezca.
  </p>
