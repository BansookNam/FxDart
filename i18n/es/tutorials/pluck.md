---
slug: pluck
title: pluck — FxDart 101
description: Tutorial de pluck en FxDart: extrae un solo campo de una lista de mapas, con un playground en vivo.
heading: <code>pluck</code>
section: 3
crumb: pluck
prev: peek.html
prevLabel: peek
next: filter.html
nextLabel: filter
---
  <p class="hero-sub">Extrae el valor de una clave concreta de cada mapa de un iterable — una sola línea para la consulta habitual de "dame solo este campo".</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>pluck</code> es una especialización diminuta y con nombre propio de
    <code>map</code> — por dentro es literalmente
    <code>map((a) =&gt; a[key], iterable)</code>. Existe porque "sacar un
    campo de una lista de registros" es lo bastante frecuente como para
    merecer su propio nombre, y en el punto de llamada se lee mejor que una
    lambda improvisada.
  </p>
  <p>
    Fíjate en que el tipo de retorno es <code>Iterable&lt;V?&gt;</code>, no
    <code>Iterable&lt;V&gt;</code>: una búsqueda en un <code>Map</code> nunca
    puede garantizar que la clave exista, así que una clave ausente pasa a
    ser <code>null</code> en el resultado en lugar de lanzar una excepción.
    Si luego necesitas descartar esos nulls, encadena con
    <a href="compact.html"><code>compact</code></a>.
  </p>
  <p>
    <strong>No hay método de cadena</strong> para <code>pluck</code> en
    <code>Fx</code>/<code>FxAsync</code>: solo existe la función data-first
    de nivel superior. Llámala directamente sobre tu fuente, o envuelve el
    resultado con <code>fx(...)</code>/<code>fxAsync(...)</code> para seguir
    encadenando después.
  </p>

  <h2>Demo 1 · Fundamentos &amp; claves ausentes</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  <p>
    <code>pluckAsync</code> está construido directamente sobre
    <code>mapAsync</code>, así que primero obtén los registros de forma
    concurrente y luego extrae lo que necesites:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>pluck</code> para obtener una lista solo con los
    títulos de los productos.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="map.html"><code>map</code></a> — la forma general que pluck especializa ·
    <a href="compact.html"><code>compact</code></a> — descarta los nulls que pluck puede producir ·
    <a href="../tutorials/prop.html"><code>prop</code></a> — el primo de pluck para un solo mapa ·
    <a href="filter.html"><code>filter</code></a> — conserva los elementos que cumplen el predicado
  </div>
