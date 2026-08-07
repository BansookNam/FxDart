---
slug: foldRight
title: foldRight — FxDart 101
description: Tutorial de foldRight en FxDart: reduce del último elemento al primero cuando el paso combinador no es asociativo, con playground en vivo.
heading: <code>foldRight</code>
section: 7
crumb: foldRight
prev: fold.html
prevLabel: fold
next: reduceLazy.html
nextLabel: reduceLazy
---
  <p class="hero-sub">Reduce del último elemento al primero: la contraparte asociativa por la derecha de <code>fold</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Para un paso asociativo — <code>+</code>, <code>max</code>, concatenar
    cadenas — la dirección da igual y
    <a href="fold.html"><code>fold</code></a> es todo lo que necesitas. Para
    todo lo demás, decide la respuesta. <code>fold</code> anida desde la
    izquierda, así que <code>[1, 2, 3]</code> con una resta es
    <code>((0 - 1) - 2) - 3</code>; <code>foldRight</code> anida desde la
    derecha y da <code>1 - (2 - (3 - 0))</code>.
  </p>
  <p>
    El uso natural es construir algo que <em>envuelve</em>: una estructura
    anidada, una cadena de decoradores, una lista enlazada donde cada paso
    tiene que sostener el resto del resultado. Escritas como fold por la
    izquierda, esas cosas salen del revés.
  </p>
  <p>
    El reductor conserva el orden de argumentos
    <code>(acc, elemento)</code> de <code>fold</code> en lugar del volteo del
    <code>foldr</code> de Haskell, así que el mismo callback sirve en ambas
    direcciones y puedes cambiar uno por otro sin reescribirlo.
  </p>
  <p>
    <code>foldRightWithIndex</code> informa de la posición de cada elemento en
    la <strong>fuente</strong>, así que el último elemento llega primero
    llevando el índice más alto: el mismo número que
    <a href="withIndex.html"><code>foldWithIndex</code></a> le habría dado a
    ese elemento. El recorrido invertido deliberadamente <em>no</em> se
    renumera 0, 1, 2: un índice que significa cosas distintas en operadores
    distintos es peor que uno que cuenta hacia atrás.
  </p>
  <p>
    Ambos son estrictos donde <code>fold</code> no lo es. Caminar hacia atrás
    exige saber dónde está el final, así que una fuente que no sea
    <code>List</code> se materializa primero y <code>foldRightAsync</code>
    vacía el stream antes de empezar: nunca lo apuntes a una fuente infinita.
  </p>

  <h2>Demo 1 · La dirección cambia la respuesta</h2>
  {{playground:0}}

  <h2>Demo 2 · Con el índice, y asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: describe un pipeline como llamadas anidadas, empezando por el paso más externo.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fold.html"><code>fold</code></a> — la misma reducción desde la izquierda ·
    <a href="reduce.html"><code>reduce</code></a> — con semilla en el primer elemento ·
    <a href="withIndex.html"><code>foldWithIndex</code></a> — el fold por la izquierda con posiciones ·
    <a href="reverse.html"><code>reverse</code></a> — la otra forma de caminar hacia atrás
  </div>
