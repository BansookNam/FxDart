---
slug: split
title: split — FxDart 101
description: Tutorial de split en FxDart: divide un iterable de caracteres según un separador, con un playground en vivo.
heading: <code>split</code>
section: 5
crumb: split
prev: chunk.html
prevLabel: chunk
next: append.html
nextLabel: append
---
  <p class="hero-sub">Divide un iterable de cadenas de un solo carácter según un carácter separador.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>split</code> es un port directo del <code>split</code> carácter a
    carácter de FxTS, y eso se nota en su firma: no recibe un
    <code>String</code> en absoluto — recibe un <code>Iterable&lt;String&gt;</code>
    de caracteres sueltos, y lo recorre carácter a carácter, acumulando
    un fragmento hasta que ve uno igual a <code>sep</code>. En Dart, la
    forma idiomática de obtener ese iterable de caracteres es
    <code>myString.split('')</code> (el propio <code>String.split</code> de Dart
    con un patrón vacío descompone una cadena en sus caracteres individuales).
  </p>
  <p>
    Un separador final produce una cadena vacía al final de la salida,
    igual que en FxTS — <code>'a,b,'</code> se divide en
    <code>('a', 'b', '')</code>, no solo en <code>('a', 'b')</code>. No hay
    forma de cadena <code>Fx</code> para <code>split</code>; llama a la función
    de nivel superior (o a <code>splitAsync</code>) directamente.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>split</code> para descomponer <code>csv</code> en
    nombres de colores según <code>'|'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="chunk.html"><code>chunk</code></a> — agrupa por tamaño fijo en lugar de por separador ·
    <a href="unicodeToArray.html"><code>unicodeToArray</code></a> — obtén un array de caracteres correcto (consciente de los grafemas) ·
    <a href="join.html"><code>join</code></a> — la operación inversa
  </div>
