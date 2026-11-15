---
slug: foldRaise
title: foldRaise — FxDart 101
description: Tutorial de foldRaise en FxDart: la primitiva bajo fxEither y fxNullable — ejecuta un bloque Raise y pliega sus tres resultados: valor, error elevado o excepción lanzada.
heading: <code>fxFoldRaise</code>
section: 13
crumb: foldRaise
prev: raise.html
prevLabel: either &amp; Raise
next: nullable.html
nextLabel: nullable
---
  <p class="hero-sub">
    Ejecuta un bloque en un ámbito <code>Raise&lt;E&gt;</code> nuevo y pliega
    lo que ocurra — un valor, un error elevado o una excepción lanzada — en
    un único tipo de resultado.
  </p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="raise.html">fxEither</a></code> convierte un bloque raise
    en un <code>Either</code>; <code><a href="nullable.html">fxNullable</a></code>
    lo convierte en un <code>T?</code>. Ambos son una sola llamada a
    <code>fxFoldRaise</code>, la única primitiva de la que derivan todos los
    constructores — el port del <code>fold</code> de Arrow. Ejecuta
    <code>block</code> con un ámbito nuevo <code>r</code> y despacha según
    cómo terminó el bloque:
  </p>
  <ul>
    <li>un retorno normal → <code>onValue(value)</code>;</li>
    <li><code>r.raise(e)</code> desde <em>este</em> ámbito →
      <code>onRaise(e)</code>;</li>
    <li>una excepción lanzada → <code>onThrow(thrown, stackTrace)</code> si
      lo pasaste; si no, se relanza;</li>
    <li>un raise desde un ámbito <em>distinto</em> → se relanza intacto, de
      modo que llega al constructor al que pertenece. Eso es lo que hace que
      los ámbitos anidados funcionen bien sin ámbito dinámico.</li>
  </ul>
  <p>
    Úsalo cuando en la frontera no quieres ni un <code>Either</code> ni un
    <code>T?</code> — una cadena de estado, una respuesta HTTP, un record, un
    tipo sealed propio — y de lo contrario construirías un
    <code>Either</code> solo para hacerle <code>switch</code> en la línea
    siguiente. También es la forma de escribir tu propio constructor:
    <code>fxEither</code> es <code>fxFoldRaise</code> con un
    <code>onRaise</code> que construye un <code>Left</code> y un
    <code>onValue</code> que construye un <code>Right</code>, y nada más.
    <code>onThrow</code> es la forma de tres cláusulas que
    <code>fxEitherCatching</code> y <code>r.recover</code> transmiten; la
    señal de raise en sí nunca se le entrega.
  </p>
  <p>
    <code>fxFoldRaiseAsync</code> es el gemelo asíncrono: el bloque y cada
    manejador pueden esperar con await, y rige la misma regla que en
    <code>fxEitherAsync</code> — eleva solo dentro de la cadena esperada. El
    ámbito se cierra cuando el plegado retorna, así que un pipeline perezoso
    que elevaría más tarde debe materializarse dentro del bloque. Se llama
    <code>fxFoldRaise</code> porque
    <code><a href="fold.html">fxFold</a></code> ya existe.
  </p>

  <h2>Demo 1 · Tres resultados, un tipo de resultado</h2>
  {{playground:0}}

  <h2>Demo 2 · Un constructor propio, anidamiento &amp; asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: sáltate el <code>Either</code> intermedio y pliega el ámbito
    directamente en el mensaje.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="raise.html"><code>fxEither</code> &amp; el ámbito <code>Raise</code></a> — el constructor construido sobre él ·
    <a href="nullable.html"><code>fxNullable</code></a> — el constructor sin información, también un solo plegado ·
    <a href="either.html"><code>Either</code></a> — <code>fold</code> sobre un valor que ya tienes ·
    <a href="typedErrors.html">errores tipados — guía completa</a>
  </div>
