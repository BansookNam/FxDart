---
slug: concat
title: concat — FxDart 101
description: Tutorial de concat en FxDart: encadena dos iterables perezosos uno detrás de otro, con un playground en vivo.
heading: <code>concat</code>
section: 6
crumb: concat
prev: prepend.html
prevLabel: prepend
next: zip.html
nextLabel: zip
---
  <p class="hero-sub">Emite perezosamente todo el primer iterable y, a continuación, todo el segundo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>concat</code> encadena dos iterables uno detrás de otro sin copiar
    ninguno de los dos a una lista nueva. Es totalmente perezoso por ambos lados:
    el segundo iterable ni se toca mientras el pipeline no tire de valores más
    allá del final del primero — así que concatenar una primera fuente costosa
    o infinita con una segunda es seguro siempre que no pidas más de lo que
    tiene la primera.
  </p>
  <p>
    <code>concatAsync</code> es transparente, igual que las primas asíncronas de
    <code>take</code> y <code>concat</code>: no serializa ninguno de los dos
    lados internamente, así que un <code>concurrent(n)</code> aguas abajo
    sigue pudiendo solapar las peticiones contra el lado que esté activo
    en ese momento.
  </p>

  <h2>Demo 1 · Fundamentos &amp; pereza</h2>
  <p>El segundo iterable es un generador con un efecto secundario — fíjate en
    que nunca llega a ejecutarse, porque <code>take(2)</code> se satisface solo
    con la primera lista:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: concatena <code>morning</code> y <code>evening</code>
    en una sola agenda.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="append.html"><code>append</code></a> — añade un único valor al final ·
    <a href="prepend.html"><code>prepend</code></a> — añade un único valor al principio ·
    <a href="zip.html"><code>zip</code></a> — empareja los elementos en vez de encadenarlos
  </div>
