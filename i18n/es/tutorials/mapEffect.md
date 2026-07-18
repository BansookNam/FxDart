---
slug: mapEffect
title: mapEffect — FxDart 101
description: Tutorial de mapEffect en FxDart: map usado por sus efectos secundarios, con un playground en vivo.
heading: <code>mapEffect</code>
section: 3
crumb: mapEffect
prev: map.html
prevLabel: map
next: flatMap.html
nextLabel: flatMap
---
  <p class="hero-sub">Idéntico a map — una convención de nombres para cuando la función está ahí por su efecto secundario.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Si miras el código fuente verás que <code>mapEffect</code> es literalmente
    <code>B mapEffect(f, iterable) =&gt; map(f, iterable);</code> — la misma
    función, la misma pereza, la misma firma. Existe únicamente para
    documentar la <em>intención</em> en el punto de llamada: usa
    <code>mapEffect</code> cuando el valor de retorno del callback importa
    menos que lo que hace por el camino (escribir en un log, guardar en una
    base de datos, incrementar un contador), y usa <code>map</code> cuando el
    valor de retorno es lo que buscas.
  </p>
  <p>
    Al ser un simple alias, todo lo que sabes de <code>map</code> se aplica
    sin cambios: es perezoso, compone con <code>.concurrent(n)</code> en el
    lado asíncrono y no tiene ningún manejo de errores propio. No hay ninguna
    razón de comportamiento para elegir uno u otro — es una señal de
    legibilidad para quien lea el pipeline después (a menudo, tú mismo).
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>El callback registra un efecto secundario y además devuelve un valor
    transformado — la misma forma que <code>map</code>, distinta intención en el punto de llamada:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  <p>
    <code>mapEffectAsync</code> se ejecuta exactamente sobre el mismo motor que
    <code>mapAsync</code>, así que <code>.concurrent(n)</code> lo paraleliza
    igual — muy útil para pipelines de "procesar y persistir":
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>mapEffect</code> para hacer <code>print</code> de una
    línea <code>'billing $&lt;dollars&gt;'</code> por cada importe mientras
    conviertes céntimos a dólares.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="map.html"><code>map</code></a> — la función en la que delega mapEffect ·
    <a href="peek.html"><code>peek</code></a> — observar sin cambiar el valor en absoluto ·
    <a href="flatMap.html"><code>flatMap</code></a> — map + aplanado ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
