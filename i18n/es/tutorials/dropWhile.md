---
slug: dropWhile
title: dropWhile — FxDart 101
description: Tutorial de dropWhile en FxDart: omite valores mientras se cumpla un predicado y luego emite el resto, con un playground en vivo.
heading: <code>dropWhile</code>
section: 5
crumb: dropWhile
prev: dropRight.html
prevLabel: dropRight
next: dropUntil.html
nextLabel: dropUntil
---
  <p class="hero-sub">Omite valores mientras un predicado devuelva true y luego emite todo lo demás, coincida o no.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>dropWhile</code> es el espejo de <code>takeWhile</code>: omite
    elementos mientras el predicado se cumpla y, en cuanto encuentra uno
    que falla, cambia definitivamente al modo "emitir todo". Ese cambio es
    permanente: una vez que <code>dropWhile</code> empieza a dejar pasar
    valores, ya nunca vuelve a descartar, aunque un elemento posterior
    también hubiera coincidido.
  </p>
  <p>
    Recurre a él para recortar un prefijo de longitud variable que no puedes
    contar de antemano: tokens iniciales tipo espacio en blanco, filas de
    cabecera, un periodo de calentamiento en un flujo de métricas. En la
    cadena <code>Fx</code> también está disponible como
    <code>skipWhile</code>, igual que <code>Iterable.skipWhile</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Una vez que el descarte se detiene en <code>3</code>, los valores
    coincidentes posteriores (el <code>2</code> del final) se conservan, no se
    vuelven a descartar:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: descarta las temperaturas mientras se mantengan por debajo de
    25 y luego conserva el resto.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="takeWhile.html"><code>takeWhile</code></a> — el inverso ·
    <a href="dropUntil.html"><code>dropUntil</code></a> — descarta también el elemento coincidente ·
    <a href="drop.html"><code>drop</code></a> — descarta por número fijo ·
    <a href="filter.html"><code>filter</code></a> — descarta coincidencias en cualquier posición, no solo en un prefijo
  </div>
