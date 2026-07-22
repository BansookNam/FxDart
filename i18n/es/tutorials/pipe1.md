---
slug: pipe1
title: pipe1 — FxDart 101
description: Tutorial de pipe1 en FxDart: aplica una función a un valor, esperándolo antes si es un Future.
heading: <code>pipe1</code>
section: 1
crumb: pipe1
prev: pipe.html
prevLabel: pipe
next: toList.html
nextLabel: toList
---
  <p class="hero-sub">Aplica una función a un valor, esperándolo antes si el valor es un Future.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>pipe1</code> es el bloque de construcción de un solo paso que
    <code>pipe</code> usa internamente: aplica <code>f</code> a
    <code>a</code>, pero si <code>a</code> es un <code>Future</code>, lo
    espera primero. Si <code>a</code> es un valor normal, <code>f</code> se
    ejecuta al momento y <code>pipe1</code> devuelve lo que devuelva
    <code>f</code> — de forma síncrona, sin ninguna envoltura
    <code>Future</code>.
  </p>
  <p>
    La gracia es que <code>f</code> nunca tiene que saber ni preocuparse de
    si el valor que recibe viene de trabajo síncrono o asíncrono aguas
    arriba: <code>pipe1</code> lo normaliza por ti. Resulta muy cómodo
    cuando estás componiendo un valor que <em>a veces</em> es un
    <code>Future</code> (por ejemplo, el resultado de un paso asíncrono
    anterior) y quieres que el siguiente paso se escriba igual en ambos
    casos.
  </p>
  <p>
    Como solo maneja un paso, puedes anidar llamadas a <code>pipe1</code>
    para componer una cadena corta, o recurrir al <code>pipe</code> completo
    (una <code>List&lt;Function&gt;</code>) cuando hay más de uno o dos
    pasos.
  </p>

  <h2>Demo 1 · Un valor normal (sin Future)</h2>
  <p>Sin ningún <code>Future</code> de por medio, <code>pipe1</code> simplemente llama a
    <code>f(a)</code> directamente y devuelve un valor normal:</p>
  {{playground:0}}

  <h2>Demo 2 · Esperar antes a un Future</h2>
  <p>
    Cuando <code>a</code> es un <code>Future</code>, <code>pipe1</code> lo
    espera antes de llamar a <code>f</code> — encadena unos cuantos para
    componer pasos asíncronos de uno en uno:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>pipe1</code> para convertir un nombre diferido en un saludo.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pipe.html"><code>pipe</code></a> — pipeline de varios pasos construido sobre pipe1 ·
    <a href="fx.html"><code>fx</code></a> — la alternativa tipada en forma de cadena ·
    <a href="delay.html"><code>delay &amp; sleep</code></a> — las utilidades asíncronas usadas arriba
  </div>
