---
slug: groupsBy
title: groupsBy — FxDart 101
description: Tutorial de groupsBy en FxDart: GroupedEvents en vivo de clave y eventos a medida que cada clave se abre, con lastFor para cerrar un grupo — con playground en vivo.
heading: <code>groupsBy</code>
section: 14
crumb: groupsBy
prev: windowOn.html
prevLabel: windowOn
next: spaceBy.html
nextLabel: spaceBy
---
  <p class="hero-sub">Grupos en vivo a medida que se abren: una clave y un stream interno de cada valor posterior que la comparte.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    El <code><a href="groupBy.html">groupBy</a></code> de la capa pull es un
    terminal: tira de todo y te entrega un <code>Map</code>.
    <code>groupsBy</code> es la versión en vivo. El primer valor de cada
    clave emite un <code>GroupedEvents</code> — un registro de esa
    <code>key</code> y un stream interno <code>events</code> — y cada
    valor posterior con la misma clave se reenvía a ese interno. Los grupos
    aparecen en el <strong>orden de primera aparición de la clave</strong>, a medida que se abren, no
    después de que la fuente se haya cerrado.
  </p>
  <p>
    Es la misma idea de <code>FxEvents</code> anidados que
    <code><a href="windowOn.html">window*</a></code>, claveada por valor
    en vez de por tiempo. Un widget puede suscribirse al interno de un grupo en el
    momento en que aparece y ver los valores posteriores conforme llegan; no
    tiene que esperar a un lote.
  </p>
  <p>
    Si se define <code>lastFor</code>, el primer evento (o la completación) de
    <code>lastFor(key)</code> <strong>completa ese grupo</strong>. Un
    valor posterior con la misma clave abre uno nuevo — un timeout de inactividad por
    usuario, una señal de «sesión terminada» por sala. Sin
    <code>lastFor</code>, los grupos se quedan abiertos hasta que la fuente completa
    (o falla, lo que hace fallar cada grupo en vivo y luego el exterior).
  </p>
  <p>
    Cancelar el exterior completa los grupos en vivo en silencio, la misma regla de RxJS 9
    que sigue la familia window. Capa de eventos de fxdart, según el
    <code>groupBy</code> de Rx.
  </p>

  <h2>Demo 1 · Grupos a medida que se abren</h2>
  {{playground:0}}

  <h2>Demo 2 · lastFor cerrando un grupo</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: agrupa SKUs por el prefijo de departamento.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — el mismo agrupamiento como un <code>Map</code> con claves, en la capa pull ·
    <a href="groupedBy.html"><code>groupedBy</code></a> — grupos de la capa pull como registros <code>(key, items)</code> encadenables ·
    <a href="windowOn.html"><code>window*</code></a> — internos en vivo rotados por conteo, disparador o reloj
  </div>
