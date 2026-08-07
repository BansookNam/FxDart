---
slug: share
title: share — FxDart 101
description: Tutorial de share en FxDart: deja que muchos oyentes consuman una sola ejecución de una cadena de eventos, y alimenta un LiveValue directamente desde un stream — con playground en vivo.
heading: <code>share</code> &amp; <code>LiveValue.from</code>
section: 14
crumb: share
prev: onErrorResume.html
prevLabel: onErrorResume
next: liveValue.html
nextLabel: LiveValue
---
  <p class="hero-sub">Una ejecución de la cadena, muchos oyentes — y la versión que recuerda su último valor para quien llegue tarde.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Todos los operadores de esta sección construyen su propio
    <code>StreamController</code>, así que la cadena que devuelven es de
    <strong>suscripción única</strong>: escúchala dos veces y el segundo
    oyente recibe un <code>StateError</code>. Ese comportamiento por defecto
    es deliberado: mantiene la cadena fría, de modo que nada se ejecuta hasta
    que alguien la consume, y mantiene honesto el estado por oyente. Pero
    implica que dos widgets no pueden observar el mismo feed con debounce,
    throttle y switchMap sin construirlo dos veces.
  </p>
  <p>
    <code>share()</code> lo arregla. Conecta con el <strong>primer</strong>
    oyente y difunde a todos los oyentes a partir de ahí, así que el trabajo
    aguas arriba ocurre una vez por muchos que estén mirando. Un temporizador
    de debounce, un socket, un map caro: uno de cada, no uno por suscriptor.
  </p>
  <p>
    Hay un límite que conviene decir claramente, porque el <code>share</code>
    de Rx no lo tiene. Rx se resuscribe cuando el número de oyentes vuelve a
    cero y luego sube otra vez; aquí <strong>no puede</strong>, porque la
    cadena de aguas arriba es de suscripción única y no hay una segunda
    ejecución que dar. Así que cuando se va el último oyente, la fuente se
    cancela y el stream compartido se cierra para siempre: a un oyente que
    llegue después se le entrega un stream ya cerrado en vez de una ejecución
    nueva. Engancha todos los oyentes antes del primer evento, o mantén uno
    vivo.
  </p>
  <p>
    <code>share()</code> tampoco <em>recuerda</em>: un oyente que llega
    después de que haya pasado un evento simplemente se lo ha perdido. Cuando
    los rezagados necesitan el estado actual —que es casi toda la UI—,
    <code><a href="liveValue.html">LiveValue</a></code> es la respuesta, y
    <code>LiveValue.from(source)</code> / <code>LiveValue.seededFrom(seed,
    source)</code> construyen uno directamente desde un stream. Esos son
    <strong>calientes</strong>: la suscripción se abre de inmediato, así que
    los valores que llegan antes de que nadie escuche siguen actualizando
    <code>value</code>, y <code>close()</code> cancela la fuente. Son
    constructores con nombre en vez de una semilla opcional para que un
    <code>T</code> nullable pueda sembrarse igualmente con null. Capa de
    eventos de fxdart, siguiendo a <code>share</code> y
    <code>shareValue</code> de Rx.
  </p>

  <h2>Demo 1 · Por qué un solo oyente es el comportamiento por defecto</h2>
  {{playground:0}}

  <h2>Demo 2 · Una ejecución, dos oyentes</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: un <code>LiveValue</code> alimentado directamente desde un stream.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="liveValue.html"><code>LiveValue</code></a> — el compartir que recuerda: los suscriptores tardíos reciben primero el valor actual ·
    <a href="tee.html"><code>tee</code></a> — la respuesta del lado pull a dos lectores sobre una pasada, sin búfer ·
    <a href="fork.html"><code>fork</code></a> — dos cursores pull independientes sobre una fuente, a costa de un búfer
  </div>
