---
slug: either
title: Either — FxDart 101
description: Tutorial de Either en FxDart: el tipo de resultado sellado con Left y Right, switch exhaustivo, fold, map, flatMap y captura de excepciones lanzadas con Either.catching.
heading: <code>Either</code>
section: 13
crumb: Either
prev: typedErrors.html
prevLabel: typed errors
next: eitherCombinators.html
nextLabel: Either combinators
---
  <p class="hero-sub">
    Un valor que es o bien un fallo <code>Left(L)</code> o bien un acierto
    <code>Right(R)</code> — el tipo frontera del sistema de errores tipados.
  </p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>Either&lt;L, R&gt;</code> convierte el fallo en parte de la
    <em>firma</em> de una función: en lugar de lanzar una excepción (invisible
    para el sistema de tipos) o devolver <code>null</code> (que no dice nada
    sobre el <em>porqué</em>), devuelves <code>Left(error)</code> o
    <code>Right(value)</code>. La clase es <code>sealed</code>, así que un
    <code>switch</code> sobre ella es exhaustivo — el compilador te recuerda
    que trates el caso de fallo.
  </p>
  <p>
    El conjunto de métodos es el que Arrow 2.x ha depurado:
    <code>fold</code> colapsa ambos lados en un único valor,
    <code>map</code>/<code>mapLeft</code> transforman uno de los dos lados,
    <code>flatMap</code> encadena un paso falible dependiente, y
    <code>getOrNull</code>/<code>getOrElse</code> hacen de puente de vuelta al
    Dart de siempre. <code>Either</code> está pensado para vivir <em>en la
    frontera</em>: dentro de un cómputo, es preferible el
    <a href="raise.html">constructor <code>either</code></a>, donde cada paso
    es un <code>r.bind</code> en línea recta en vez de una pirámide de
    <code>flatMap</code>.
  </p>

  <h2>Demo 1 · Left, Right y switch exhaustivo</h2>
  {{playground:0}}

  <h2>Demo 2 · fold, map, mapLeft, flatMap</h2>
  {{playground:1}}

  <h2>Demo 3 · dot shorthands (Dart ≥ 3.10)</h2>
  <p>
    <code>Either</code> incluye las factorías <code>const</code>
    <code>Either.left</code> / <code>Either.right</code> para que los
    <em>dot shorthands</em> de Dart 3.10 se resuelvan contra ella: allí donde
    el tipo del contexto ya es <code>Either</code> — una posición de retorno,
    una rama de una expresión switch, el lado derecho de
    <code>==</code> — puedes omitir el nombre del tipo y escribir
    <code>.left(error)</code> / <code>.right(value)</code>. Son los mismos
    objetos que <code>Left(…)</code> / <code>Right(…)</code>, solo que
    inferidos a partir del contexto.
  </p>
  {{playground:3}}

  <h2>Pruébalo tú</h2>
  <p>
    Las excepciones y los errores tipados se mantienen estrictamente
    separados: una excepción <em>lanzada</em> atraviesa el código de errores
    tipados sin que nada la toque. Para capturar un throw dentro de un
    <code>Either</code>, sé explícito con <code>Either.catching</code> (tipo
    de fallo <code>Object</code>) o <code>Either.catchingWith</code> (que
    primero convierte la excepción a tu propio tipo de fallo). Ejercicio: haz
    que el parseo fallido imprima <code>Left(bad input)</code> en vez de
    reventar.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="raise.html">constructor <code>either</code></a> — construye Eithers con código en línea recta ·
    <a href="accumulate.html">acumulación</a> — recoge todos los fallos, no solo el primero ·
    <a href="eitherPipelines.html">Either × pipelines</a> — <code>rights</code>, <code>lefts</code>, <code>sequence</code> sobre cadenas ·
    <a href="typedErrors.html">errores tipados — guía completa</a>
  </div>
