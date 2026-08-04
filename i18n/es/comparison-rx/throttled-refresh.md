---
slug: throttled-refresh
title: Aplicar throttle al botón de refresco — RxDart vs FxDart
description: Dejar pasar un toque por ventana de 300 ms — throttleTime sobre el stream de toques vs la cadena throttle equivalente en la capa de eventos de fxdart 0.7.3.
heading: Aplicar throttle al botón de refresco
order: 44
tier: 4
functions: fxEvents, throttle
domain: users
verdict: tie
async: true
noBenchmark: timing
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
    Ya no difieren. El throttling es limitar la tasa de <em>llegadas en
    el tiempo</em> — una propiedad de cuándo ocurren los eventos, no de
    los valores — y ambos paneles colapsan ahora el requisito en un solo
    operador sobre el stream de toques. El <code>throttleTime(300ms)</code>
    de RxDart y el <code>fxEvents(...).throttle(300ms)</code> de fxdart
    implementan la misma ventana de borde inicial (el primer toque emite
    y abre la ventana, el resto de la ráfaga se traga; el borde final
    está a una bandera de distancia en cualquiera de los dos lados), con
    la suscripción, la contabilidad de ventanas y la terminación todas
    dentro del operador.
  </p>
  <p>
    fxdart&nbsp;0.7.3 llegó aquí absorbiendo deliberadamente el enfoque
    Rx para el lado push: <code>fxEvents</code> es una cadena envoltorio
    sobre <code>Stream</code>s llanos — no una extensión, así que
    convive con cualquier biblioteca de streams sin un solo conflicto de
    miembros. El catálogo de operadores de RxDart sigue siendo mucho más
    amplio que la capa de eventos de fxdart; para los verbos temporales
    cotidianos como este, los dos son ahora intercambiables. Si cada
    toque superviviente tuviera luego que disparar trabajo async real y
    tipado, <code>.pull()</code> llevaría el stream al pipeline
    <code>FxAsync</code> dirigido por demanda.
  </p>
