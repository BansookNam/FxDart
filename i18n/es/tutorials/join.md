---
slug: join
title: join — FxDart 101
description: Tutorial de join en FxDart: concatena los elementos de un pipeline en una sola cadena, data-first, con un playground en vivo.
heading: <code>join</code>
section: 7
crumb: join
prev: size.html
prevLabel: size
next: groupBy.html
nextLabel: groupBy
---
  <p class="hero-sub">Concatena todos los elementos en una sola cadena, con un separador entre ellos.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>join</code> es un operador terminal: tira de todo el pipeline,
    llama a <code>toString()</code> en cada elemento y cose los resultados
    intercalando <code>sep</code> entre ellos.
  </p>
  <p>
    Fíjate en el orden de los argumentos — el <code>join</code> de nivel
    superior, data-first, pone el <strong>separador primero</strong>:
    <code>join(', ', iterable)</code>. Esa es la convención de FxTS (data-first
    en todas partes), y es justo la contraria del método
    <code>Iterable.join(separator)</code> del propio Dart, que toma el iterable
    como receptor y el separador como su único argumento.
  </p>
  <p>
    Esa diferencia se filtra a la forma encadenada de un modo sutil: en la
    cadena <strong>síncrona</strong>, <code>.join(...)</code> es simplemente el
    <code>Iterable.join</code> nativo de Dart, cuyo separador por defecto es
    <code>''</code> (vacío) si se omite. Pero <code>FxAsync.join</code> está
    escrito explícitamente en FxDart y usa como separador por defecto
    <code>','</code> — igual que el propio valor por defecto de FxTS. No des por
    hecho que ambas cadenas se comportan igual cuando omites el argumento.
  </p>

  <h2>Demo 1 · Fundamentos &amp; los dos valores por defecto</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, y su valor por defecto distinto</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: une las columnas en una única fila de cabecera CSV, separadas por <code>','</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sort.html"><code>sort</code></a> — ordena los elementos antes de unirlos ·
    <a href="map.html"><code>map</code></a> — da formato a cada elemento antes de unirlos ·
    <a href="size.html"><code>size</code></a> — el otro terminal sencillo de cadena/conteo
  </div>
