---
slug: pipe
title: pipe — FxDart 101
description: Tutorial de pipe en FxDart: composición de funciones de izquierda a derecha sobre un valor, con tipado dinámico — y por qué las cadenas fx() son la alternativa tipada.
heading: <code>pipe</code>
section: 1
crumb: pipe
prev: fx.html
prevLabel: fx
next: pipe1.html
nextLabel: pipe1
---
  <p class="hero-sub">Hace pasar un valor por una lista de funciones, de izquierda a derecha — con tipado dinámico.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    En FxTS, <code>pipe(x, f, g, h)</code> es un pipeline currificado y
    totalmente tipado: TypeScript tiene suficientes sobrecargas y trucos de
    genéricos para inferir el tipo que sale de cada paso.
    <strong>Dart no puede hacer esto.</strong> No existe un truco de
    sobrecarga con genéricos variádicos, así que el <code>pipe</code> de
    FxDart es honesto sobre el compromiso: recibe una
    <code>List&lt;Function&gt;</code> normal y hace pasar un valor
    <code>dynamic</code> por cada una en orden. Cada función recibe lo que
    devolvió la anterior, sin ninguna comprobación estática de tipos entre
    medias.
  </p>
  <p>
    Es decir, <code>pipe</code> sigue funcionando y sigue leyéndose bien
    para una transformación corta y desechable — pero un paso que espere el
    tipo equivocado solo fallará en <em>tiempo de ejecución</em>, y el tipo
    del resultado del pipeline entero es simplemente <code>dynamic</code>.
    Si un paso de la lista devuelve un <code>Future</code>,
    <code>pipe</code> lo espera automáticamente antes de pasar el valor al
    siguiente paso, así que las funciones síncronas y asíncronas pueden
    convivir en la misma lista.
  </p>
  <p>
    Para cualquier cosa que vayas a conservar y mantener, prefiere la cadena
    <code>fx()</code>: <code>fx(x).map(f).filter(g)</code> está totalmente
    tipada, tiene autocompletado y detecta los tipos incompatibles en tiempo
    de compilación — es precisamente la alternativa tipada a este tipo de
    pipeline. Recurre a <code>pipe</code> cuando los pasos sean dinámicos por
    naturaleza (por ejemplo, construidos a partir de una lista de funciones
    en tiempo de ejecución) o cuando estés prototipando rápido.
    <code>pipeLazy</code> es la misma idea, pero diferida: devuelve una
    función que puedes llamar más tarde en lugar de ejecutarse al momento.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Un pipeline corto construido con las funciones data-first de FxDart:</p>
  {{playground:0}}

  <h2>Demo 2 · La pega, sin adornos</h2>
  <p>
    Un paso que espera el tipo equivocado compila sin problemas y solo
    revienta cuando llega a ejecutarse — esto es justo lo que las cadenas
    <code>fx()</code> están diseñadas para evitar:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: haz pasar una lista de números por un paso de filtrado y un paso de suma.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fx.html"><code>fx</code></a> — la alternativa tipada en forma de cadena ·
    <a href="pipe1.html"><code>pipe1</code></a> — un único paso de pipe, consciente de sync/async ·
    <a href="toList.html"><code>toList</code></a> — el paso final habitual de un pipe
  </div>
