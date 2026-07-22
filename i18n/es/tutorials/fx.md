---
slug: fx
title: fx — FxDart 101
description: Tutorial de fx en FxDart: el modelo de cadenas perezosas — fx, fxAsync, fxStream — y por qué nada se ejecuta hasta que un operador terminal tira de los valores.
heading: <code>fx</code>
section: 1
crumb: fx
next: pipe.html
nextLabel: pipe
---
  <p class="hero-sub">Envuelve una secuencia en un pipeline perezoso y encadenable: el corazón tipado de FxDart.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Todo este curso apunta a una sola idea: la <strong>cadena</strong>.
    <code>fx(iterable)</code> envuelve cualquier <code>Iterable&lt;T&gt;</code> en un
    <code>Fx&lt;T&gt;</code>: un objeto con métodos al estilo de FxTS como
    <code>.map()</code>, <code>.filter()</code> y <code>.take()</code>
    colgando de él. Cada una de esas llamadas devuelve un <em>nuevo</em>
    <code>Fx</code> que envuelve un poco más de cómputo perezoso. Nada se
    ejecuta todavía. <code>Fx</code> solo empieza a trabajar cuando llamas a un
    <strong>operador terminal</strong> — <code>toList()</code>,
    <code>each()</code>, <code>consume()</code>, <code>reduce()</code> y
    compañía —, que tira de los valores a través de toda la cadena, uno a uno,
    desde el terminal hasta la fuente.
  </p>
  <p>
    Esta pereza es lo que permite a FxDart encadenar sin riesgo sobre secuencias
    enormes o infinitas (<code>range</code>, <code>cycle</code>, <code>repeat</code>):
    mientras algo aguas abajo — normalmente <code>take(n)</code> — decida
    cuántos valores pedir de verdad, los pasos de aguas arriba solo se
    ejecutan esas veces.
  </p>
  <p>
    <code>fx</code> es la mitad <em>síncrona</em> de la cadena. Sus equivalentes
    asíncronos son <code>fxAsync</code>, que envuelve un
    <code>FxAsyncIterable</code> (lo que obtienes de <code>toAsync</code>,
    <code>fromStream</code> o cualquier función <code>*Async</code>), y
    <code>fxStream</code>, un atajo que envuelve directamente un <code>Stream</code>
    de Dart. Ambos devuelven una cadena <code>FxAsync&lt;T&gt;</code> cuyos
    métodos aceptan funciones que pueden devolver un <code>Future</code>, y
    cuyos operadores terminales devuelven todos un <code>Future</code> que
    esperas con <code>await</code>. Pasa de síncrono a asíncrono a mitad de cadena con
    <code>.toAsync()</code>.
  </p>
  <p>
    ¿Y por qué existe esto, en lugar de llamar sin más a funciones de nivel
    superior como <code>map(f, iterable)</code>? Porque Dart no puede tipar un
    <code>pipe</code> variádico como sí hace TypeScript en FxTS (lo verás en la
    siguiente lección): el encadenado con <code>fx()</code> es la forma que tiene
    FxDart de ofrecer pipelines totalmente tipados y con autocompletado.
  </p>

  <h2>Demo 1 · Nada se ejecuta hasta el operador terminal</h2>
  <p>Fíjate en que <code>calls</code> se queda en 0 justo después de construir la cadena, y
    salta en cuanto <code>toList()</code> tira de verdad de los 5 valores:</p>
  {{playground:0}}

  <h2>Demo 2 · fxAsync y fxStream</h2>
  <p>
    <code>fxAsync</code> envuelve un <code>FxAsyncIterable</code> (aquí, desde
    <code>toAsync</code>); <code>fxStream</code> envuelve un <code>Stream</code>
    directamente. Ambos te dan los mismos métodos de cadena, en versión asíncrona:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: construye una cadena que se quede con las puntuaciones de 60 o más, las duplique
    como puntos extra y tome solo los 2 primeros resultados.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pipe.html"><code>pipe</code></a> — la alternativa de tipado dinámico ·
    <a href="toList.html"><code>toList</code></a> — el operador terminal más habitual ·
    <a href="each.html"><code>each</code></a> — operador terminal para efectos secundarios ·
    <a href="consume.html"><code>consume</code></a> — operador terminal que descarta los resultados
  </div>
