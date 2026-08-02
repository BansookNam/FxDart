---
slug: race
title: race — FxDart 101
description: Tutorial de FxEvents.race en FxDart: el primer stream en emitir gana y todos los perdedores se cancelan de inmediato — caché contra red en una línea — con playground en vivo.
heading: <code>race</code>
section: 14
crumb: race
prev: switchMap.html
prevLabel: switchMap
next: liveValue.html
nextLabel: LiveValue
---
  <p class="hero-sub">El primer candidato en emitir gana: su stream entero se refleja, y todos los demás candidatos se cancelan en el acto.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Pregunta a la caché y a la red a la vez; quédate con quien responda
    primero. Prueba tres mirrors de descarga; conserva el más rápido.
    <code>FxEvents.race(candidates)</code> se suscribe a todos los
    candidatos a la vez, y el primer <em>evento</em> en cualquier parte lo
    decide: ese evento se entrega, y todo candidato perdedor se
    <strong>cancela de inmediato</strong> — no se silencia, se cancela. Sus
    sockets se cierran, su trabajo se detiene, sus eventos nunca ocurren.
  </p>
  <p>
    Sé preciso sobre qué gana: el primer evento en cualquier parte elige al
    ganador, y a partir de ahí la carrera <strong>refleja el stream ganador
    al completo</strong> — cada evento posterior que produzca fluye a
    través, y la carrera se cierra cuando el ganador se cierra. Un
    <em>error</em> también puede ganar: un endpoint roto pero rápido vence
    a uno sano pero lento, que es exactamente el comportamiento honesto —
    preguntaste quién responde primero, y «falló» es una respuesta. Protege
    los campos lentos y poco fiables con
    <code><a href="timeout.html">timeout</a></code>/<code><a href="retry.html">retry</a></code>
    en cada candidato antes de ponerlos a correr.
  </p>
  <p>
    Los candidatos que se cierran sin emitir nunca se retiran en silencio;
    si todos lo hacen — o la lista de candidatos está vacía — la carrera se
    cierra vacía. Fíjate en la dirección de la cancelación frente a su
    vecino: <code><a href="switchMap.html">switchMap</a></code> cancela el
    <em>más viejo</em> de streams sucesivos, <code>race</code> cancela el
    <em>más lento</em> de streams simultáneos. Capa de eventos de fxdart,
    según el <code>race</code>/<code>amb</code> de Rx.
  </p>

  <h2>Demo 1 · Caché contra red, perdedores cancelados</h2>
  {{playground:0}}

  <h2>Demo 2 · Los errores pueden ganar, los candidatos vacíos se retiran</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: el más rápido de tres mirrors.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — cancelar el más viejo en lugar del más lento ·
    <a href="timeout.html"><code>timeout</code></a> — acota cada candidato antes de la carrera ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>FxEvents.merge</code>, cuando quieres los eventos de todos, no un ganador
  </div>
