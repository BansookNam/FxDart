---
slug: prepend
title: prepend — FxDart 101
description: Tutorial de prepend en FxDart: añade un valor al principio de un iterable perezoso, con un playground en vivo.
heading: <code>prepend</code>
section: 6
crumb: prepend
prev: append.html
prevLabel: append
next: concat.html
nextLabel: concat
---
  <p class="hero-sub">Emite primero un valor y después todos los valores de la fuente.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>prepend</code> es el espejo de <code>append</code>: emite
    <code>a</code> primero y luego deja pasar la fuente. Como la fuente no se
    toca hasta que realmente se tira de ella, anteponer un valor es barato por
    muy grande o costosa que sea la fuente — sin copias, sin desplazar índices,
    solo un valor extra por delante del resto.
  </p>
  <p>
    <code>prependAsync</code> acepta además un <code>Future</code> como
    <code>a</code>; se espera primero, antes de que la primera petición llegue a
    la fuente subyacente.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con un valor futuro</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: antepón <code>'mix'</code> al principio de los pasos.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="append.html"><code>append</code></a> — añade un valor al final en su lugar ·
    <a href="concat.html"><code>concat</code></a> — une dos iterables completos ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
