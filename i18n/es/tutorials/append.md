---
slug: append
title: append — FxDart 101
description: Tutorial de append en FxDart: añade un valor al final de un iterable perezoso, con un playground en vivo.
heading: <code>append</code>
section: 6
crumb: append
prev: split.html
prevLabel: split
next: prepend.html
nextLabel: prepend
---
  <p class="hero-sub">Emite todos los valores de la fuente y, al final, un valor extra.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>append</code> es la forma más sencilla de pegar un único valor final
    a una secuencia perezosa sin materializar nada: se limita a emitir toda la
    fuente y luego emite <code>a</code> una vez que la fuente
    se ha agotado. Como la fuente solo se consume cuando se tira de ella, esto
    funciona bien incluso si calcularla es costoso — el valor extra es de verdad
    lo último que se produce.
  </p>
  <p>
    En el lado asíncrono, <code>a</code> puede ser a su vez un <code>Future</code>:
    <code>appendAsync</code> lo espera solo cuando la fuente de aguas arriba ha terminado, así que un
    valor de "cierre" lento no bloquea nada antes de tiempo.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con un valor futuro</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: añade <code>'cool'</code> al final de los pasos.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="prepend.html"><code>prepend</code></a> — añade un valor al principio en su lugar ·
    <a href="concat.html"><code>concat</code></a> — une dos iterables completos ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
