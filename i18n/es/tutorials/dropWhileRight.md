---
slug: dropWhileRight
title: dropWhileRight — FxDart 101
description: Tutorial de dropWhileRight en FxDart: recorta la racha final más larga que cumple un predicado, con playground en vivo.
heading: <code>dropWhileRight</code>
section: 5
crumb: dropWhileRight
prev: dropWhile.html
prevLabel: skipWhile
next: dropUntil.html
nextLabel: dropUntil
---
  <p class="hero-sub">Descarta la racha más larga del <em>final</em> de una fuente en la que se cumple un predicado: recorta la cola.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Este es el operador de recorte. Ceros finales, líneas en blanco finales,
    una cola de filas de relleno: cualquier cosa que quieras fuera del final
    sin contarla antes, que es todo lo que
    <a href="dropRight.html"><code>dropRight</code></a> sabe hacer.
  </p>
  <p>
    Solo se descarta la racha que llega hasta el final. Una racha coincidente
    en mitad de la fuente no es un sufijo y se queda exactamente donde está;
    es lo único que conviene contrastar con tu intuición, ya que
    <a href="filter.html"><code>filter</code></a> y
    <a href="reject.html"><code>reject</code></a> sí la habrían borrado.
  </p>
  <p>
    A diferencia de <a href="takeWhileRight.html"><code>takeWhileRight</code></a>,
    este va emitiendo sobre la marcha. Una racha coincidente se retiene en vez
    de emitirse, porque podría resultar ser el sufijo; el primer elemento que
    <em>falla</em> el predicado demuestra que no lo era y libera la racha
    entera de golpe. Así el coste en memoria es la racha más larga, no la
    longitud de la fuente, y los valores siguen fluyendo mientras la fuente
    está abierta.
  </p>
  <p>
    Sobre una <code>List</code> la racha se busca caminando hacia atrás desde
    el final, así que el predicado solo ve esa racha; sobre cualquier otra
    fuente se prueba cada elemento en orden. Mantén el predicado puro.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, y el reparto</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: descarta los ceros finales y conserva el resto.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="takeWhileRight.html"><code>takeWhileRight</code></a> — el complemento: conserva esa misma racha ·
    <a href="dropRight.html"><code>dropRight</code></a> — recorta un tramo final por cantidad ·
    <a href="dropWhile.html"><code>skipWhile</code></a> — la misma idea desde el principio ·
    <a href="reject.html"><code>whereNot</code></a> — borra coincidencias en cualquier parte, no solo al final
  </div>
