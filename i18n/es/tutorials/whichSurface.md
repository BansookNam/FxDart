---
slug: whichSurface
title: ¿Qué superficie? — FxDart 101
description: Página de decisión de FxDart: a qué superficie pertenece un trabajo — fx() para datos en mano, concurrent para I/O acotado, fxEvents para el tiempo, Either para fallos que maneja el llamador.
heading: ¿Qué superficie?
section: 1
crumb: which surface
next: fx.html
nextLabel: fx
---
  <p class="hero-sub">Cuatro superficies, un solo import. Elige la superficie que es el trabajo, y quédate en ella.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    FxDart no son cuatro bibliotecas dentro de un gabán. Es un solo paquete porque
    un programa real cruza estos trabajos, y los nombres se mantienen cuando
    lo haces. El error es empezar por una lista de funciones. Empieza por el
    trabajo:
  </p>
  <table>
    <tr><th>El trabajo es…</th><th>Empieza con</th><th>No</th></tr>
    <tr>
      <td>Datos ya en mano; solo hace falta una parte</td>
      <td><code><a href="fx.html">fx(iterable)</a></code></td>
      <td>envolver un <code>map</code>/<code>where</code>/<code>take</code> de una línea</td>
    </tr>
    <tr>
      <td>I/O sobre una colección conocida, como mucho <em>n</em> en vuelo, orden conservado</td>
      <td><code>.toAsync().map(f).concurrent(n)</code> o <code><a href="mapConcurrent.html">.mapConcurrent(n, f)</a></code></td>
      <td><code>Future.wait(xs.map(f))</code></td>
    </tr>
    <tr>
      <td>Los valores llegan cuando llegan (pulsaciones, tics, sockets)</td>
      <td><code><a href="fxEvents.html">fxEvents(stream)</a></code></td>
      <td>un pipeline pull con <code>sleep</code></td>
    </tr>
    <tr>
      <td>El llamador maneja el fallo</td>
      <td><code><a href="raise.html">either</a></code> / <code><a href="mapEither.html">mapEither</a></code> / <code><a href="attempt.html">attempt</a></code> en la superficie en la que ya estás</td>
      <td><code>throw</code> para errores de dominio; <code>null</code> con la razón perdida</td>
    </tr>
  </table>
  <p>
    Los nombres pull ganan en caso de colisión. <code>takeUntil</code> es el predicado de FxTS;
    el análogo de la capa de eventos es <code><a href="stopOn.html">stopOn</a></code>.
    Una palabra, un significado. Cruza en una costura con nombre:
    <code>.toAsync()</code> eleva datos a demanda,
    <code>.pull()</code> eleva eventos a demanda,
    <code>.toStream()</code> va al otro lado.
  </p>

  <div class="callout">
    <strong>La regla del canal 0.8.10.</strong>
    <code>attempt</code> <strong>después</strong> de
    <code><a href="retryOn.html">retryOn</a></code> /
    <code>retryOnError</code>, nunca antes. Esos operadores vigilan el
    canal de error; una vez que un fallo es un <code>Left</code> no queda nada
    ahí que reintentar.
  </div>

  <p>
    Dos trabajos que cruzan superficies se tratan como tutoriales propios:
    <a href="job-search.html">búsqueda con debounce</a> (tiempo → gana la consulta
    más reciente → parseo tipado) y
    <a href="job-fetch.html">fetch concurrente acotado</a> (un límite, orden
    conservado, cada fallo conservado). La rampa de acceso pull sigue empezando en
    <a href="fx.html"><code>fx</code></a>.
  </p>

  <h2>Demo · cuatro trabajos, cuatro superficies</h2>
  <p>
    El mismo import. Cada bloque es el programa más pequeño que pertenece a
    esa fila de la tabla:
  </p>
  {{playground:0}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fx.html"><code>fx</code></a> — la cadena pull ·
    <a href="concurrent.html"><code>concurrent</code></a> — el límite de I/O ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — la cadena push ·
    <a href="typedErrors.html">errores tipados</a> — fallos como valores ·
    <a href="job-search.html">búsqueda con debounce</a> ·
    <a href="job-fetch.html">fetch concurrente acotado</a>
  </div>
