---
slug: comparison-rx
title: RxDart vs FxDart — dos modelos, lado a lado
description: 50 tareas reales resueltas dos veces —streams de RxDart frente a pipelines pull de FxDart—, cada pareja ejecutable en el navegador y con un veredicto honesto sobre qué modelo encaja.
---
  <h1>RxDart vs FxDart</h1>
  <p class="hero-sub">
    La misma tarea real, resuelta dos veces: RxDart a la izquierda, FxDart
    a la derecha. Las dos versiones se ejecutan en tu navegador e imprimen
    exactamente la misma salida — compara los dos modelos y decide qué
    modelo es en realidad tu problema.
  </p>

  <p>
    Estas dos bibliotecas no son tanto rivales como
    <strong>complementos</strong>. RxDart extiende el <code>Stream</code>
    de Dart — un modelo <em>push</em> en el que el productor decide cuándo
    llegan los valores, lo que hace naturales los operadores ligados al
    reloj (<code>debounceTime</code>, <code>combineLatest</code>,
    <code>switchMap</code>) y el multicast (<code>BehaviorSubject</code>).
    FxDart trabaja sobre iterables — un modelo <em>pull</em> en el que el
    consumidor decide cuándo pedir, lo que hace naturales la pereza, el
    manejo tipado de errores y la concurrencia acotada en orden
    (<code><a href="../tutorials/concurrent.html">.concurrent(n)</a></code>),
    y convierte el backpressure en un no-problema: no tirar
    <em>es</em> el backpressure. Los dos se encuentran en los puentes —
    <code><a href="../tutorials/streams.html">fromStream / toStream</a></code> —
    y varios de los ejemplos de abajo usan las dos bibliotecas juntas a
    propósito.
  </p>

  <p>
    Un apunte de honestidad antes de la lista: cuando un problema va
    genuinamente de <em>eventos en el tiempo</em> — entrada del usuario,
    tickers, sockets — un stream es la forma correcta para él, y algunos
    veredictos de abajo lo dicen sin rodeos. Lo que las parejas exponen es
    cuántas veces un problema que se resuelve con un stream es en realidad
    un <em>pipeline de datos</em> disfrazado de stream: una descarga
    acotada, una transformación por lotes, un rastreo paginado. Para esos,
    la versión pull es más corta, ordenada, tipada y no necesita ciclo de
    vida de suscripción alguno.
  </p>

  <p>
    <span class="badge verdict-fxdart">Gana FxDart</span> — el modelo pull encaja mejor con este problema ·
    <span class="badge verdict-tie">Empate</span> — ambos modelos lo expresan con limpieza ·
    <span class="badge verdict-rxdart">Terreno de RxDart</span> — genuinamente push/temporal; RxDart es la herramienta adecuada ·
    <span class="badge badge-async">async</span> — usa pipelines asíncronos
  </p>
