---
slug: feeds-in-order
title: Dos feeds, estrictamente en orden — RxDart vs FxDart
description: La cola del log de ayer seguida del log de hoy como una sola lista numerada — concatWith secuenciando suscripciones frente a concat secuenciando tirones.
heading: Dos feeds, estrictamente en orden
order: 17
tier: 2
functions: fx, concat, map
domain: logs
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Una revisión de incidente necesita la cola del log de
    <strong>ayer</strong> seguida del log de <strong>hoy</strong> como una
    sola lista numerada — la primera entrada de hoy no debe aparecer nunca
    antes de la última de ayer. Los datos están en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ambas bibliotecas escriben «este feed, y luego aquel» como un solo
    operador, pero cada modelo garantiza el orden con su propio mecanismo.
    El <code>concatWith</code> de RxDart es un secuenciador de
    <em>suscripciones</em>: no se suscribe al stream de hoy hasta que el
    de ayer dispara <code>done</code>, así que el orden se mantiene
    incluso si ambas fuentes están vivas y la de hoy hubiera estado lista
    para emitir antes. El <code>concat</code> de FxDart es un secuenciador
    de <em>demanda</em>: la cadena tira del segundo iterable solo después
    de agotar el primero, y con dos listas en memoria eso es todo el orden
    que hay que organizar.
  </p>
  <p>
    Ese hueco de mecanismo importa exactamente cuando las fuentes son
    genuinamente push — un stream que empieza a emitir en cuanto alguien
    se suscribe necesita la suscripción diferida de
    <code>concatWith</code>, donde un pipeline pull tendría primero que
    almacenar el feed aún no deseado. Sobre datos fijos los dos colapsan
    en las mismas siete líneas y el mismo <code>map</code>. Empate: el
    operador es vocabulario compartido, y cada modelo lo implementa con la
    herramienta que ya tenía.
  </p>
