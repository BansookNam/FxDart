---
slug: switch-to-newest-search
title: Solo importa la búsqueda más nueva — RxDart vs FxDart
description: Una consulta más nueva abandona la búsqueda en vuelo — switchMap en un operador vs un contador de épocas artesanal que descarta resultados obsoletos al aterrizar.
heading: Solo importa la búsqueda más nueva
order: 45
tier: 4
functions: fx, map
domain: users
verdict: rxdart
async: true
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
    «Lo más nuevo cancela lo más viejo» es una afirmación sobre
    <em>suscripciones</em>, y solo el modelo push las tiene.
    <code>switchMap</code> es el requisito entero: cada consulta arranca
    un stream de búsqueda interno, y la llegada de una consulta más nueva
    des-suscribe la vieja, así que a un resultado obsoleto no le queda
    ningún oyente al que llegar. Arrancan tres búsquedas, sobreviven dos
    resultados, y nada de esa lógica aparece en el código del usuario.
  </p>
  <p>
    Un pipeline pull no puede expresar esto — para cuando una cadena
    tiraría del primer resultado, el hecho interesante (existe una
    consulta más nueva) vive fuera de la secuencia. Así que el lado
    FxDart fabrica el switch a mano: un contador de épocas se incrementa
    por consulta, cada búsqueda recuerda su época, y un resultado se
    descarta al llegar si ya no es el más nuevo. Añade la contabilidad de
    terminación (un <code>Completer</code> para el stream, esperando la
    última búsqueda en vuelo) y solo entonces una pequeña cadena
    <code>fx</code> para formatear los supervivientes. Imprime las mismas
    líneas, pero es una reimplementación manual de la
    cancelación-por-más-nuevo. Este es el caso de uso que define a
    <code>switchMap</code>, y el veredicto se sigue de ahí: aquí usa
    RxDart.
  </p>
