---
slug: sortByDesc
title: sortByDesc — FxDart 101
description: Tutorial de sortByDesc en FxDart — ordena por cualquier clave comparable, descendente, sin el truco de negar números. Con playground en vivo.
heading: <code>sortByDesc</code>
section: 7
crumb: sortByDesc
prev: sortBy.html
prevLabel: sortBy
next: partition.html
nextLabel: partition
---
  <p class="hero-sub">Ordena por cualquier clave comparable, descendente — el truco de la negación, jubilado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Los rankings quieren su valor más grande primero, y hasta ahora la
    única línea posible era <code>sortBy((a)&nbsp;=&gt;&nbsp;-key)</code> —
    un truco que funciona <em>solo con números</em>. Las fechas, las
    cadenas y cualquier otro <code>Comparable</code> no tienen signo menos.
    <code>sortByDesc</code> es <code><a href="sortBy.html">sortBy</a></code>
    con la comparación invertida: misma extracción de claves (cada clave se
    calcula exactamente una vez), mismos atajos sin boxing para claves
    <code>double</code>/<code>int</code>/<code>String</code>, mismo
    contrato de nunca mutar la entrada.
  </p>
  <p>
    La forma clásica que reemplaza es el ranking «top N»:
    <code>sortByDesc(key).take(n)</code> se lee tal como está escrito,
    donde la variante ascendente necesitaba la negación <em>y</em> un
    comentario explicándola. Para «lo más nuevo primero» sobre fechas es
    directamente la única escritura posible.
  </p>
  <p>
    Adición nativa de Dart — el nombre sigue al
    <code>sortedByDescending</code> de Kotlin. Cuando solo necesitas el
    elemento más grande y no el orden completo, sáltate el orden entero:
    <code><a href="maxBy.html">maxBy</a></code> es O(n).
  </p>

  <h2>Demo 1 · Rankings sin negación</h2>
  {{playground:0}}

  <h2>Demo 2 · Claves que los números no pueden fingir</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: lo más nuevo primero sin negar nada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="sortBy.html"><code>sortBy</code></a> — el gemelo ascendente ·
    <a href="maxBy.html"><code>maxBy</code></a> — una sola pasada cuando solo importa el primero ·
    <a href="take.html"><code>take</code></a> — la otra mitad de todo «top N»
  </div>
