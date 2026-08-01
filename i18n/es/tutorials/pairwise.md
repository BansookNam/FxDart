---
slug: pairwise
title: pairwise — FxDart 101
description: Tutorial de pairwise en FxDart: cada elemento emparejado con su sucesor — deltas, variaciones día a día, detección de huecos — con playground en vivo.
heading: <code>pairwise</code>
section: 5
crumb: pairwise
prev: windowed.html
prevLabel: windowed
next: split.html
nextLabel: split
---
  <p class="hero-sub">Cada elemento emparejado con su sucesor: <code>[a, b, c]</code> se convierte en <code>((a, b), (b, c))</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    «¿Cuánto <em>cambió</em>?» necesita dos elementos a la vez — el
    anterior y el actual — y un <code><a href="map.html">map</a></code>
    normal solo ve uno. Los apaños habituales son un bucle con índices
    (<code>list[i&nbsp;-&nbsp;1]</code>, con su riesgo de descuadre
    incluido) o hacer zip de una lista consigo misma desplazada en uno.
    <code>pairwise()</code> es esa idea como operador: produce registros
    <code>(anterior, actual)</code>, perezosamente, con
    <em>n&nbsp;−&nbsp;1</em> pares para <em>n</em> elementos. Con menos de
    dos elementos no produce nada — no hay par que formar.
  </p>
  <p>
    Los campos del registro mantienen ambos lados al alcance:
    <code>p.$2&nbsp;-&nbsp;p.$1</code> es el delta,
    <code>p.$2.compareTo(p.$1)</code> la dirección. Es exactamente
    <code><a href="windowed.html">windowed(2)</a></code> con registros
    tipados en lugar de listas de dos elementos — recurre a
    <code>windowed</code> cuando el vecindario crezca más allá de dos.
  </p>
  <p>
    Extensión de fxdart (sin contraparte en FxTS), inspirada en el
    <code>pairwise</code> de RxDart. La forma async no computa nada hasta
    que se le pide y compone con
    <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · Deltas entre lecturas</h2>
  {{playground:0}}

  <h2>Demo 2 · Dirección del cambio</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: encuentra los huecos en una secuencia de timestamps.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="windowed.html"><code>windowed</code></a> — vecindarios de más de dos ·
    <a href="zip.html"><code>zip</code></a> — emparejar dos secuencias <em>distintas</em> ·
    <a href="scan.html"><code>scan</code></a> — llevar estado en lugar de mirar uno atrás
  </div>
