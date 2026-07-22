---
slug: toList
title: toList — FxDart 101
description: Tutorial de toList en FxDart: el operador terminal que materializa una cadena perezosa en una List, en versión síncrona y asíncrona.
heading: <code>toList</code>
section: 1
crumb: toList
prev: pipe1.html
prevLabel: pipe1
next: each.html
nextLabel: each
---
  <p class="hero-sub">Materializa un iterable perezoso: tira de todos los valores y los recoge en una List.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>toList</code> es el <strong>operador terminal</strong> por excelencia:
    es lo que de verdad ejecuta una cadena que, hasta ese momento, no era más
    que un plan. Llamar a <code>.toList()</code> extrae en orden todos los
    valores que queden en el iterable y los recoge en una
    <code>List&lt;T&gt;</code> de verdad. Todo lo que hay aguas arriba —cada
    <code>.map()</code>, <code>.filter()</code>, <code>.take()</code>— solo se
    ejecuta porque <code>toList</code> pidió valores.
  </p>
  <p>
    Eso también significa que <code>toList</code> es justo el operador que
    <em>no</em> debes llamar directamente sobre una fuente infinita o no
    acotada (<code>range</code> sin fin, <code>cycle</code>,
    <code>repeat</code> con un número enorme de repeticiones): intentará tirar de ella para
    siempre. Acótala primero con <code>take(n)</code> y luego llama a
    <code>toList</code> sobre el resultado acotado.
  </p>
  <p>
    La versión asíncrona, <code>toListAsync</code> (o <code>.toList()</code>
    sobre una cadena <code>FxAsync</code>), espera cada elemento conforme lo
    extrae y devuelve un <code>Future&lt;List&lt;T&gt;&gt;</code>. Combinada
    con <code>.concurrent(n)</code> aguas arriba, las esperas individuales
    pueden solaparse aunque la lista final siga llegando en el orden original.
  </p>

  <h2>Demo 1 · Fundamentos &amp; pereza</h2>
  <p>Fíjate en que <code>map</code> solo se ejecuta de verdad para los 3
    valores que <code>take(3)</code> deja pasar — de entre un millón:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  <p>
    <code>.toList()</code> sobre una cadena <code>FxAsync</code> espera cada
    elemento y te devuelve la lista entera de golpe; añade
    <code>.concurrent(n)</code> aguas arriba para solapar las esperas
    individuales:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: materializa en una List los 4 primeros cuadrados de un rango enorme.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="each.html"><code>each</code></a> — operador terminal para efectos secundarios en vez de una List ·
    <a href="consume.html"><code>consume</code></a> — operador terminal que descarta los resultados por completo ·
    <a href="fx.html"><code>fx</code></a> — la cadena que toList termina ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
