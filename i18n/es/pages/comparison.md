---
slug: comparison
title: Dart vs FxDart — tareas reales, lado a lado
description: 50 tareas del mundo real resueltas dos veces —una en Dart puro y otra con FxDart—, cada pareja ejecutable en el navegador y con un veredicto honesto sobre cuál se lee mejor.
---
  <h1>Dart vs FxDart</h1>
  <p class="hero-sub">
    La misma tarea real, resuelta dos veces: Dart puro a la izquierda, FxDart
    a la derecha. Las dos versiones se ejecutan en tu navegador e imprimen
    exactamente la misma salida — compáralas y decide por ti mismo.
  </p>

  <p>
    Un apunte de honestidad antes de la lista: el <code>Iterable</code>
    integrado de Dart ya es perezoso, y las cadenas sencillas de
    <code>where</code>/<code>map</code> son código Dart perfectamente válido.
    FxDart no está aquí para ganarles. Lo que aporta es
    <strong>vocabulario</strong>
    (<code><a href="../tutorials/groupBy.html">groupBy</a></code>,
    <code><a href="../tutorials/chunk.html">chunk</a></code>,
    <code><a href="../tutorials/zip.html">zip</a></code>,
    <code><a href="../tutorials/scan.html">scan</a></code>,
    <code><a href="../tutorials/uniqBy.html">uniqBy</a></code>,
    <code><a href="../tutorials/partition.html">partition</a></code> —
    cosas que el Dart de base te obliga a escribir a mano),
    <strong>composición</strong> (una única cadena tipada
    <code><a href="../tutorials/fx.html">fx()</a></code> en lugar de
    llamadas anidadas y variables intermedias) y, sobre todo,
    <strong>control de la concurrencia</strong>:
    <code><a href="../tutorials/concurrent.html">.concurrent(n)</a></code> ejecuta
    un pipeline asíncrono n elementos a la vez, en orden, algo que el Dart puro
    solo puede aproximar con pools de workers escritos a mano. Cada ejemplo
    lleva una insignia de veredicto, y algunos dicen que el Dart nativo está
    bien. De eso se trata: cuando un ejemplo <em>sí</em> dice que gana FxDart,
    puedes creértelo.
  </p>

  <p>
    <span class="badge verdict-fxdart">Gana FxDart</span> — aquí es claramente mejor ·
    <span class="badge verdict-tie">Empate</span> — igual de buenos, elige por gusto ·
    <span class="badge verdict-native">Dart nativo basta</span> — Dart puro lo resuelve bien ·
    <span class="badge badge-async">async</span> — usa pipelines asíncronos
  </p>
