---
slug: raise
title: el constructor either &amp; el ámbito Raise — FxDart 101
description: Tutorial de raise en FxDart: los constructores either y eitherAsync, y el vocabulario del ámbito Raise — bind, ensure, ensureNotNull, recover, withError, raise.
heading: <code>either</code> &amp; el ámbito <code>Raise</code>
section: 13
crumb: either &amp; Raise
prev: either.html
prevLabel: Either
next: nullable.html
nextLabel: nullable
---
  <p class="hero-sub">
    Ejecuta un bloque en un ámbito <code>Raise&lt;E&gt;</code>: código en
    línea recta que puede cortocircuitar con un error tipado. Un <code>E</code>
    elevado se convierte en <code>Left</code>; un retorno normal, en
    <code>Right</code>.
  </p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    El constructor le entrega a tu bloque un ámbito <code>r</code> — el port
    del <code>either&nbsp;{&nbsp;}</code> de Arrow en Kotlin. Todo cuelga de
    él; escribe <code>r.</code> y descubre el vocabulario completo:
  </p>
  <ul>
    <li><code>r.bind(either)</code> / <code>r.bindAll(eithers)</code> —
      desenvuelve un acierto o cortocircuita con el fallo.</li>
    <li><code>r.ensure(cond, () => err)</code> — el <code>require</code> de
      los errores tipados.</li>
    <li><code>r.ensureNotNull(x, () => err)</code> — devuelve un valor no
      nulo, con promoción de tipo.</li>
    <li><code>r.recover(block, onRaise)</code> — trata un error elevado en un
      ámbito anidado y sigue adelante.</li>
    <li><code>r.withError(transform, block)</code> — adapta un tipo de error
      <em>distinto</em> a este ámbito.</li>
    <li><code>r.raise(err)</code> — cortocircuita directamente; devuelve
      <code>Never</code>, así que el análisis de flujo sabe que la ejecución
      se detiene.</li>
  </ul>
  <p>
    Por dentro esto <em>no</em> es un encadenamiento de <code>flatMap</code>:
    un <code>bind</code> fallido lanza una señal privada, etiquetada con el
    ámbito, que el constructor captura en su frontera. Por eso los retornos
    tempranos, los bucles y los <code>if</code> funcionan sin más dentro del
    bloque, y por eso los constructores anidados nunca capturan los errores de
    los demás. <code>eitherAsync</code> es el gemelo asíncrono — mismo
    vocabulario, con <code>await</code> permitido (elevar errores solo dentro
    de la misma cadena de awaits).
  </p>

  <h2>Demo 1 · ensure &amp; ensureNotNull</h2>
  {{playground:0}}

  <h2>Demo 2 · bind — el asesino de la pirámide de flatMap</h2>
  {{playground:1}}

  <h2>Demo 3 · recover, withError &amp; raise</h2>
  {{playground:2}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: haz que <code>checkAge</code> falle con un error tipado en vez
    de lanzar una excepción — <code>ensureNotNull</code> para el parseo,
    <code>ensure</code> para el límite de edad.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>Dos reglas.</strong> (1) Nunca devuelvas un pipeline
    <em>perezoso</em> desde un bloque raise — materialízalo con
    <code>toList()</code> dentro, o usa los
    <a href="eitherPipelines.html">terminales ansiosos de Either</a>; un raise
    diferido falla ruidosamente con <code>RaiseLeakedError</code>. (2) Nunca
    uses un <code>catch</code> pelado dentro de un bloque raise — usa
    <code>catching</code>/<code>catchingAsync</code>, que siempre dejan pasar
    la señal de cortocircuito.
  </div>

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="either.html"><code>Either</code></a> — el tipo frontera ·
    <a href="nullable.html"><code>nullable</code></a> — el gemelo sin información que devuelve <code>T?</code> ·
    <a href="accumulate.html">acumulación</a> — recoge todos los fallos ·
    <a href="typedErrors.html">errores tipados — guía completa</a>
  </div>
