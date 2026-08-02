---
slug: withLatestFrom
title: withLatestFrom — FxDart 101
description: Tutorial de withLatestFrom en FxDart: sella cada evento de la fuente con el último valor de otro stream — combinación unilateral para consultas de contexto — con playground en vivo.
heading: <code>withLatestFrom</code>
section: 14
crumb: withLatestFrom
prev: combineLatest.html
prevLabel: combineLatest
next: switchMap.html
nextLabel: switchMap
---
  <p class="hero-sub">En cada evento de la <em>fuente</em>, emite <code>combine</code> de ese evento y el último valor del otro stream — el otro lado es contexto, no disparador.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Una petición se dispara y debe llevar la versión de configuración
    vigente <em>en ese momento</em>. Llega un pedido y debe cotizarse al
    tipo de cambio de <em>ahora mismo</em>. Hay dos streams implicados, pero
    no son iguales: uno conduce, el otro se consulta.
    <code>withLatestFrom(other, combine)</code> codifica esa asimetría —
    cada evento de la fuente emite <code>combine(event, latestOfOther)</code>,
    mientras que los eventos en <code>other</code> actualizan su valor
    recordado y no emiten <strong>nada</strong>.
  </p>
  <p>
    Esa unilateralidad es toda la diferencia con
    <code><a href="combineLatest.html">combineLatest</a></code>, donde ambos
    lados disparan. Elige preguntándote: ¿una actualización de configuración
    debe producir salida <em>por sí sola</em>? Si sí,
    <code>combineLatest</code>; si la configuración solo importa cuando una
    petición resulta dispararse, <code>withLatestFrom</code>.
  </p>
  <p>
    Los bordes, con honestidad. Los eventos de la fuente que disparan antes
    de que <code>other</code> haya producido algo se
    <strong>descartan</strong> — no hay último valor con el que sellarlos
    (dale a <code>other</code> una semilla con <code>startWith</code> si esa
    pérdida no te conviene). La vida útil sigue a la fuente: cuando se
    cierra, la cadena se cierra, y el cierre de <code>other</code>
    simplemente se ignora — un feed en vivo en el lado del contexto nunca
    mantiene abierto el pipeline. Capa de eventos de fxdart, según el
    operador Rx del mismo nombre.
  </p>

  <h2>Demo 1 · Sellando peticiones con la configuración actual</h2>
  {{playground:0}}

  <h2>Demo 2 · El otro lado nunca dispara, nunca bloquea</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: cotiza cada pedido al tipo de cambio de su momento.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — ambos lados disparan ·
    <a href="sampleOn.html"><code>sampleOn</code></a> — la idea de disparador y último valor, sin combinar ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>startWith</code>, para sembrar el lado del contexto
  </div>
