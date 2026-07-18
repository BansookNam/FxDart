---
slug: throwError
title: throwError — FxDart 101
description: Tutorial de throwError en FxDart: convierte una acción que lanza errores en una función unaria reutilizable, con playground en vivo.
heading: <code>throwError</code>
section: 10
crumb: throwError
prev: unless.html
prevLabel: unless
next: throwIf.html
nextLabel: throwIf
---
  <p class="hero-sub">Devuelve una función unaria que siempre lanza — para lugares donde se espera una función, no una sentencia.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>throw</code> es una sentencia en Dart, así que no puedes colocarlo
    directamente en un sitio que espera un valor de función.
    <code>throwError(toError)</code> resuelve eso: le das una función que
    construye un <code>Object</code> (una excepción o un error) a partir del
    valor problemático y recibes a cambio un
    <code>Never Function(T)</code> que puedes pasar a cualquier sitio donde se
    espere un callback — lo más habitual, como el <code>orElse</code> de
    <a href="cases.html"><code>cases</code></a>, para convertir un «no coincidió
    nada» en un fallo rotundo en lugar de un valor de reserva silencioso.
  </p>
  <p>
    Como el tipo de retorno es <code>Never</code>, llamarla siempre lanza;
    nunca llega a devolver un valor de tipo <code>T</code>. Envuelve cualquier
    punto de llamada en <code>try</code>/<code>catch</code> si quieres
    recuperarte en lugar de dejar que el error se propague.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Como valor de reserva de cases</h2>
  <p>
    En lugar de pasar de largo en silencio, <code>throwError</code> convierte
    un valor sin coincidencia en un fallo ruidoso y capturable:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: construye una función que lance «no implementado» y actívala.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="throwIf.html"><code>throwIf</code></a> — lanza de forma condicional, sin una función constructora aparte ·
    <a href="cases.html"><code>cases</code></a> — el sitio donde más se usa throwError: como orElse ·
    <a href="when.html"><code>when</code></a> / <a href="unless.html"><code>unless</code></a> — transformaciones condicionales que no lanzan ·
    <a href="find.html"><code>find</code></a> — devuelve null en vez de lanzar cuando no hay coincidencia
  </div>
