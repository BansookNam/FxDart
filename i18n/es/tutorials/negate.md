---
slug: negate
title: negate — FxDart 101
description: Tutorial de negate en FxDart: convierte cualquier predicado en su opuesto lógico, con un playground en vivo.
heading: <code>negate</code>
section: 10
crumb: negate
prev: memoize.html
prevLabel: memoize
next: not.html
nextLabel: not
---
  <p class="hero-sub">Devuelve un predicado que es la negación lógica del que le pasas.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>negate(f)</code> te devuelve un predicado nuevo que da
    <code>!f(x)</code> para cualquier <code>x</code>. Resulta más útil cuando ya
    tienes un predicado con nombre (<code>isEven</code>, <code>isEmpty</code>,
    el resultado de un <code>matches(pattern)</code>) y quieres su opuesto como
    valor de función — para <code>filter</code>, <code>reject</code> o
    cualquier otro sitio donde se espere un predicado — sin volver a definir la lógica.
  </p>
  <p>
    No lo confundas con <a href="not.html"><code>not</code></a>: <code>not</code>
    invierte un único valor <code>bool</code>, mientras que <code>negate</code> invierte
    toda una <em>función predicado</em>. <code>negate(f)</code> equivale más o menos a
    <code>(x) =&gt; not(f(x))</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Negar un predicado de la librería</h2>
  <p>
    <code>negate</code> se compone con cualquier predicado que ya exista en la librería,
    como <a href="isEmpty.html"><code>isEmpty</code></a>, que trabaja sobre valores:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>negate(isVowel)</code> para quedarte solo con las consonantes.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="not.html"><code>not</code></a> — niega un único valor booleano ·
    <a href="filter.html"><code>filter</code></a> / <a href="reject.html"><code>reject</code></a> — el destino habitual de un predicado negado ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — un predicado sobre valores para combinar con negate ·
    <a href="when.html"><code>when</code></a> — aplica un callback solo cuando se cumple un predicado
  </div>
