---
slug: with-latest-config
title: Sellar cada petición con la config más reciente — RxDart vs FxDart
description: Cada petición saliente lleva la versión de config vigente en ese instante — el mismo operador withLatestFrom en ambos lados, rxdart y fxEvents.
heading: Sellar cada petición con la config más reciente
order: 41
tier: 4
functions: fxEvents, withLatestFrom
domain: general
verdict: tie
async: true
noBenchmark: timing
---
  <h2>Requisito</h2>
  <p>
    Una app dispara cuatro peticiones a la API mientras, en segundo
    plano, los despliegues suben la versión de config
    <code>v1 → v2 → v3</code> en desplazamientos fijos. Cada petición
    debe sellarse con la versión de config que estaba vigente
    <em>cuando la petición se disparó</em> — y un cambio de config por sí
    solo no debe emitir nada. Imprime las cuatro peticiones selladas.
    Ambos calendarios están simulados en el código; las dos versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    No difieren. Este es el hermano asimétrico de
    <code>combineLatest</code> — un stream dirige, el otro solo se
    <em>consulta</em> — y ambos paneles lo nombran de
    la misma manera: <code>withLatestFrom</code> emite por petición,
    sellada con la config más fresca vista hasta ahora, y guarda
    silencio cuando solo cambia la config. Sin andamiaje de fusión
    etiquetada y sin pliegue con <code>scan</code>: las dos cadenas son
    idénticas operador por operador.
  </p>
  <p>
    La capa de eventos de fxdart absorbe el enfoque Rx para el
    lado push: <code>fxEvents</code> es una cadena envoltorio fina sobre
    <code>Stream</code>s llanos — nunca una extensión, así que no
    colisiona con nada, rxdart incluido. El catálogo de operadores de
    RxDart sigue siendo mucho más amplio; fxdart mantiene pequeño el
    núcleo de eventos y cruza al pipeline pull tipado con
    <code>.pull()</code> cuando el procesamiento por valor crece. Para
    sellar un stream vivo con el último valor de otro, los dos lados son
    equivalentes: empate.
  </p>
