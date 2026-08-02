---
slug: throttled-refresh
title: Aplicar throttle al botón de refresco — RxDart vs FxDart
description: Dejar pasar un toque por ventana de 300 ms — throttleTime sobre el stream de toques vs el envoltorio de callback throttle de fxdart cableado al stream a mano.
heading: Aplicar throttle al botón de refresco
order: 41
tier: 4
functions: fx, throttle, map
domain: users
verdict: rxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un usuario machaca el botón de refresco: toques en
    0/50/100/400/450/800&nbsp;ms. Deja pasar como mucho un refresco por
    ventana de 300&nbsp;ms, tomando el <em>primer</em> toque de cada
    ventana — de modo que se disparan exactamente tres refrescos (toques
    0, 3 y 5). Imprime qué toques pasaron después de que el stream se
    cierre. El calendario de toques está simulado en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El throttling es limitar la tasa de <em>llegadas en el tiempo</em> —
    una propiedad de cuándo ocurren los eventos, no de los valores en sí.
    Eso es territorio de streams, y RxDart colapsa el requisito entero en
    un operador: <code>throttleTime(300ms)</code> abre una ventana en el
    primer toque, se traga el resto de la ráfaga, y reabre en el
    siguiente toque tras la ventana — suscripción, contabilidad de
    ventanas y terminación, todo resuelto.
  </p>
  <p>
    Los pipelines de FxDart no tienen reloj por diseño — una cadena pull
    ve demanda, no tiempos de llegada — así que su <code>throttle</code>
    es el <em>envoltorio de callback</em> al estilo FxTS. Implementa
    exactamente la misma ventana de borde inicial, pero lo cableas al
    stream tú mismo: suscribirse, alimentar cada toque a la función con
    throttle, recoger los supervivientes, seguir la terminación con un
    <code>Completer</code>, y solo entonces entregar la lista a una
    cadena tipada para el formateo. Los mismos tres toques, visiblemente
    más fontanería. Este es de RxDart, limpiamente: el throttling es un
    problema push, y el stream de toques es donde debe resolverse.
  </p>
