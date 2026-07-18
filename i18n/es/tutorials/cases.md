---
slug: cases
title: cases — FxDart 101
description: Tutorial de cases en FxDart: construye una tabla de despacho de predicado/mapeador con un valor por defecto opcional, con playground en vivo.
heading: <code>cases</code>
section: 10
crumb: cases
prev: throwIf.html
prevLabel: throwIf
next: add.html
nextLabel: add
---
  <p class="hero-sub">Construye una tabla de despacho de predicado/mapeador, con un valor por defecto opcional.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>cases</code> construye una función de coincidencia a partir de una lista de pares
    <code>(predicado, mapeador)</code>: prueba cada par en orden y, al primero
    cuyo predicado devuelve true, le aplica su mapeador para producir el
    resultado. Es el sustituto funcional de una cadena de
    <code>if</code>/<code>else if</code>, y compone bien con
    <code>map</code>: la función devuelta es una función unaria normal
    <code>T -&gt; R</code> que puedes pasar directamente.
  </p>
  <p>
    <strong>Esta forma difiere de FxTS a propósito.</strong> El
    <code>cases</code> de FxTS es variádico: cada par
    <code>[predicate, mapper]</code> se pasa como su propio argumento final, con
    una función suelta opcional al final que actúa como valor por defecto, y los genéricos
    sobrecargados de TypeScript tipan cada aridad a mano. Dart no tiene ni
    genéricos variádicos ni sobrecargas por aridad, así que no hay forma de
    aceptar "cualquier número de pares" y conservar una comprobación de tipos
    real. La versión de FxDart toma en su lugar una única <code>List</code> de
    <code>(predicado, mapeador)</code> en forma de <strong>registros</strong>
    —el tipo tupla de Dart— más un parámetro con nombre <code>orElse</code>
    aparte, para que el valor por defecto nunca se confunda con un par más.
  </p>
  <p>
    Si no coincide nada y no se pasa <code>orElse</code>, <code>cases</code>
    recurre a devolver el propio <code>value</code>, lo cual solo compila en el
    punto de llamada si <code>T</code> resulta satisfacer también <code>R</code>;
    en caso contrario lanza un <code>StateError</code> en tiempo de ejecución.
    En la práctica, pasa siempre <code>orElse</code> salvo que tengas la certeza
    de que tus predicados son exhaustivos.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Un pipeline de calificaciones</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: clasifica cada tamaño como <code>'small'</code> (&lt;10),
    <code>'medium'</code> (&lt;30) o <code>'large'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="when.html"><code>when</code></a> / <a href="unless.html"><code>unless</code></a> — un solo predicado, mismo tipo de resultado ·
    <a href="throwError.html"><code>throwError</code></a> — un orElse habitual cuando no encontrar coincidencia debe ser fatal ·
    <a href="always.html"><code>always</code></a> — un orElse constante ·
    <a href="matches.html"><code>matches</code></a> — un predicado que puedes conectar a un caso
  </div>
