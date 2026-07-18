---
slug: matches
title: matches — FxDart 101
description: Tutorial de matches en FxDart: la forma currificada de isMatch, un predicado listo para usar con filter.
heading: <code>matches</code>
section: 9
crumb: matches
prev: isMatch.html
prevLabel: isMatch
next: identity.html
nextLabel: identity
---
  <p class="hero-sub"><code>isMatch</code> currificado: fijas un patrón una vez y recibes un predicado reutilizable.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>isMatch(target, pattern)</code> necesita los dos argumentos de golpe,
    lo que lo hace incómodo de pasar a <code>filter</code>, <code>find</code>,
    <code>every</code> o a cualquier otro sitio que espere un
    <code>bool Function(A)</code> de un solo argumento. <code>matches(pattern)</code>
    captura el patrón en un cierre y devuelve justo esa forma:
    <code>matches(pattern)(target) == isMatch(target, pattern)</code>. Construyes
    el predicado una vez y lo reutilizas en todo un pipeline.
  </p>
  <p>
    Esta es la versión de currificación de FxDart para una función de dos
    argumentos allí donde Dart no puede inferir un curry general — mira la función
    de nivel superior obsoleta <code>curry</code> si te pica la curiosidad de por qué
    no existe una versión genérica —, pero una forma currificada hecha a medida como
    esta funciona de maravilla.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Enchufarlo directamente en filter/find</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>matches</code> para construir un predicado para <code>{'active': true}</code> y filtra <code>users</code> con él.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="isMatch.html"><code>isMatch</code></a> — la función de dos argumentos que esto currifica ·
    <a href="filter.html"><code>filter</code></a> — el sitio más habitual donde enchufarlo ·
    <a href="find.html"><code>find</code></a> — quédate solo con la primera coincidencia ·
    <a href="predicates.html"><code>predicates</code></a> — más comprobaciones ya hechas y listas para filter
  </div>
