---
slug: mapNotNull
title: mapNotNull — FxDart 101
description: Tutorial de mapNotNull y firstNotNullOf en FxDart: transforma y filtra en una sola etapa perezosa, donde un null del callback significa saltar el elemento — con un playground en vivo.
heading: <code>mapNotNull</code> · <code>firstNotNullOf</code>
section: 3
crumb: mapNotNull
prev: attach.html
prevLabel: attach
next: filter.html
nextLabel: where
---
  <p class="hero-sub">Transforma y filtra en un solo paso: el callback devuelve el nuevo valor, o <code>null</code> para saltarlo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Mucho mapeo es <em>parcial</em>: parsear una cadena que quizá no sea un
    número, buscar una clave que quizá falte. La versión larga es un
    <code>where</code> que ejecuta el trabajo para comprobarlo y un
    <code>map</code> que lo ejecuta otra vez para quedárselo, o bien
    <code>fxCompact(fxMap(f, xs))</code>, que apila dos etapas perezosas.
    <code>mapNotNull(f, xs)</code> hace ambas cosas en una sola etapa:
    <code>f</code> devuelve el nuevo valor, y un resultado <code>null</code>
    significa <em>salta este elemento</em>. <code>f</code> se ejecuta una vez
    por elemento, y solo cuando se tira de ese elemento.
  </p>
  <p>
    El tipo de resultado <code>B</code> está acotado a <code>Object</code>,
    así que <code>mapNotNull(int.tryParse, xs)</code> es un
    <code>Iterable&lt;int&gt;</code>, no <code>int?</code>: un
    <code>null</code> nunca puede significar <em>emite null</em>.
    <code>firstNotNullOf(f, xs)</code> es la misma idea como operación
    terminal: devuelve el primer resultado no nulo de <code>f</code> y se
    detiene ahí, o <code>null</code> cuando todos los resultados son
    <code>null</code> (o la entrada está vacía). Mientras que
    <code><a href="find.html">find</a></code> devuelve el
    <em>elemento</em> que coincidió, <code>firstNotNullOf</code> devuelve la
    proyección, sin una segunda llamada para obtenerla.
  </p>
  <p>
    Las variantes asíncronas son <code>mapNotNullAsync</code> y
    <code>firstNotNullOfAsync</code>; <code>f</code> puede devolver un
    <code>Future</code>. <code>mapNotNullAsync</code> está construido sobre
    <code>fxMapAsync</code>, que es seguro en paralelo, así que
    <code><a href="concurrent.html">concurrent(n)</a></code> ejecuta
    <em>n</em> callbacks a la vez; <code>firstNotNullOfAsync</code> tira de
    un elemento cada vez y cancela la fuente en el primer acierto. En la
    cadena son <code>fx(xs).mapNotNull(f)</code> y
    <code>fx(xs).firstNotNullOf(f)</code>. Adición nativa de Dart (no forma
    parte de FxTS): el <code>mapNotNull</code> y el
    <code>firstNotNullOfOrNull</code> de Kotlin, el <code>filter_map</code>
    de Rust.
  </p>

  <h2>Demo 1 · Parsear lo que se puede parsear</h2>
  {{playground:0}}

  <h2>Demo 2 · Búsquedas asíncronas que pueden fallar</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: deja de parsear cada respuesta dos veces.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="map.html"><code>map</code></a> — cuando todo elemento tiene un resultado ·
    <a href="filter.html"><code>where</code></a> — conserva elementos, sin cambiarlos ·
    <a href="compact.html"><code>nonNulls</code></a> — descarta los null que ya están ahí ·
    <a href="find.html"><code>find</code></a> — el primer elemento que coincide, no su proyección
  </div>
