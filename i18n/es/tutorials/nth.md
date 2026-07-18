---
slug: nth
title: nth — FxDart 101
description: Tutorial de nth en FxDart: obtén con seguridad el elemento de un índice, con null si queda fuera de rango, y un playground en vivo.
heading: <code>nth</code>
section: 8
crumb: nth
prev: last.html
prevLabel: last
next: find.html
nextLabel: find
---
  <p class="hero-sub">Devuelve el elemento que está en un índice dado, o <code>null</code> si el índice queda fuera de rango.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>nth</code> recorre el iterable y se detiene en cuanto llega a
    <code>index</code>, así que nunca consume más de <code>index + 1</code>
    elementos — barato incluso sobre una secuencia perezosa enorme, y mucho
    más barato que materializarla entera solo para indexar en una <code>List</code>.
    Un índice negativo, o uno más allá del final, simplemente da <code>null</code>;
    a diferencia de la indexación de arrays de algunos lenguajes, aquí los índices
    no dan la vuelta para contar desde el final — el índice tiene que ser una posición
    válida y no negativa.
  </p>
  <p>
    <code>nth</code> no tiene método de cadena: llama directamente a la función
    de nivel superior (o a su gemela asíncrona) sobre cualquier <code>Iterable</code>
    o cadena <code>Fx</code>, ya que <code>Fx</code> <em>es</em> un
    <code>Iterable</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Pereza &amp; async</h2>
  <p>Pedir el índice 3 solo consume 4 elementos del rango de un millón — demostrado con un contador de <code>peek</code>:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>nth</code> para imprimir al medallista de plata (índice 1), o <code>'unclaimed'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="head.html"><code>head</code></a> — atajo para <code>nth(0, ...)</code> ·
    <a href="last.html"><code>last</code></a> — el último elemento ·
    <a href="find.html"><code>find</code></a> — localiza por predicado en vez de por índice ·
    <a href="slice.html"><code>slice</code></a> — extrae un rango entero
  </div>
