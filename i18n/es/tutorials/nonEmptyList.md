---
slug: nonEmptyList
title: NonEmptyList (Nel) — FxDart 101
description: Tutorial de NonEmptyList en FxDart: un extension type de coste cero para listas que no pueden estar vacías — head y first son totales, y transporta los errores acumulados.
heading: <code>NonEmptyList</code> · <code>Nel</code>
section: 13
crumb: NonEmptyList
prev: nullable.html
prevLabel: nullable
next: accumulate.html
nextLabel: accumulation
---
  <p class="hero-sub">
    Una lista con la garantía estática de contener al menos un elemento — el
    portador de errores de la API de acumulación. Coste cero: un extension
    type, borrado en tiempo de ejecución.
  </p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    «Una lista de errores de validación» tiene un caso límite incómodo: ¿qué
    significa una lista de errores <em>vacía</em>? <code>NonEmptyList</code>
    (alias <code>Nel</code>) elimina la pregunta en el sistema de tipos: si
    tienes uno en la mano, hay al menos un elemento, así que
    <code>head</code> es total y no puede lanzar, a diferencia de
    <code>List.first</code>. Eso es justo lo que necesita la
    <a href="accumulate.html">acumulación</a>:
    <code>EitherNel&lt;E, A&gt;</code> = <code>Either&lt;Nel&lt;E&gt;, A&gt;</code>,
    donde un <code>Left</code> siempre lleva al menos un error.
  </p>
  <p>
    Es el análogo en Dart del <code>value class NonEmptyList</code> de Arrow:
    un <em>extension type</em> sobre <code>List</code> — cero asignaciones de
    memoria, borrado en tiempo de ejecución y, como
    <code>implements Iterable</code>, cualquier pipeline de fxdart y
    cualquier bucle <code>for</code> lo aceptan directamente. La invariante es
    disciplina en tiempo de compilación: construye uno únicamente mediante
    <code>NonEmptyList.of(head, [tail])</code> o
    <code>NonEmptyList.orNull(list)</code> (que devuelve <code>null</code>
    para una lista vacía — la comprobación de vacuidad ocurre exactamente una
    vez, en la frontera). Un cast como <code>list as Nel&lt;int&gt;</code>
    saltaría esa comprobación por tu cuenta y riesgo.
  </p>

  <h2>Demo 1 · of, orNull, head &amp; tail</h2>
  {{playground:0}}

  <h2>Demo 2 · map, +, y pipelines</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: completa <code>summarize</code> — con el caso <code>null</code>
    ya tratado, <code>nel.length</code> y <code>nel.head</code> no pueden
    fallar.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="accumulate.html">acumulación</a> — donde <code>Nel</code> transporta todos los fallos ·
    <a href="either.html"><code>Either</code></a> — <code>toEitherNel()</code> eleva un fallo a un <code>Nel</code> de un solo elemento ·
    <a href="head.html"><code>firstOrNull</code></a> — el acceso nullable-first que vuelve total ·
    <a href="typedErrors.html">errores tipados — guía completa</a>
  </div>
