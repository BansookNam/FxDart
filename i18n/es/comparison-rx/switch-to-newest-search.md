---
slug: switch-to-newest-search
title: Solo importa la búsqueda más nueva — RxDart vs FxDart
description: Una consulta más nueva abandona la búsqueda en vuelo — el mismo operador switchMap en ambos lados, rxdart y la cadena fxEvents de fxdart.
heading: Solo importa la búsqueda más nueva
order: 40
tier: 4
functions: fxEvents, switchMap
domain: users
verdict: tie
async: true
noBenchmark: timing
---
  <h2>Requisito</h2>
  <p>
    Un usuario teclea tres consultas — <code>fx</code>, luego
    <code>fxdar</code> 40&nbsp;ms después, luego <code>fxdart</code> tras
    una pausa. Cada búsqueda tarda 150&nbsp;ms, así que la segunda
    consulta llega mientras la primera búsqueda sigue en vuelo: el primer
    resultado debe descartarse, jamás mostrarse. Imprime solo los
    resultados supervivientes, y luego cuántas búsquedas arrancaron
    frente a cuántas se entregaron. El calendario está simulado en el
    código; las dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ya no difieren. «Lo más nuevo cancela lo más viejo» es una
    afirmación sobre <em>suscripciones</em>, y desde fxdart 0.7.3 la
    capa <code>fxEvents</code> las tiene: su <code>switchMap</code>
    mapea cada consulta a un stream de búsqueda interno y des-suscribe
    el anterior en el momento en que llega una consulta más nueva, así
    que a un resultado obsoleto no le queda ningún oyente al que llegar.
    Arrancan tres búsquedas, sobreviven dos resultados, y nada de esa
    lógica aparece en el código del usuario — en ninguno de los dos
    paneles. El contador de épocas artesanal y la contabilidad de
    terminación que el viejo panel FxDart necesitaba han desaparecido.
  </p>
  <p>
    fxdart 0.7.3 absorbió el enfoque Rx exactamente para esta clase de
    requisito: <code>fxEvents</code> es una cadena envoltorio fina sobre
    <code>Stream</code>s llanos — nunca una extensión, así que convive
    con cualquier otra biblioteca de streams, rxdart incluido. El
    catálogo de operadores de RxDart sigue siendo mucho más amplio;
    cuando los resultados supervivientes necesiten procesamiento real
    por valor, cruza a la cadena pull tipada con <code>.pull()</code>.
    Para el caso de uso que define a <code>switchMap</code>, los paneles
    son ahora equivalentes operador por operador: empate.
  </p>
