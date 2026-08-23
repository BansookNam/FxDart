---
slug: waitAll
title: waitAll — FxDart 101
description: Tutorial de waitAll en FxDart: un resultado en cuanto todos los streams se han cerrado, más zip, concat, combineLatestAll, mergeWith y raceWith — con playground en vivo.
heading: <code>waitAll</code>, <code>zip</code> &amp; friends
section: 14
crumb: waitAll
prev: race.html
prevLabel: race
next: combine.html
nextLabel: combine
---
  <p class="hero-sub">Combinar muchos streams en uno: esperarlos a todos, emparejarlos por índice, reproducirlos en secuencia o dejar que compitan.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>FxEvents.waitAll(sources)</code> es el
    <code>Future.wait</code> de los streams. Emite exactamente
    <strong>un</strong> evento — una lista con el <em>último</em> valor de
    cada fuente, en el orden de las fuentes — en cuanto todas se han cerrado,
    y luego se cierra él. Ese es el caso del panel de control: tres paneles
    cargan de forma independiente y la pantalla se dibuja cuando entra el más
    lento. Una fuente que se cierra sin haber emitido nada significa que no
    hay resultado completo que informar, así que no se emite nada en absoluto.
  </p>
  <p>
    <code>FxEvents.zip</code> empareja las fuentes por <strong>índice</strong>:
    el 1.er evento de cada fuente junto, luego el 2.º de cada una, y así
    sucesivamente. La fuente que va por delante se almacena hasta que la más
    lenta la alcanza, y el resultado se cierra en cuanto una fuente cerrada se
    queda sin búfer: ya no puede formarse ningún par más.
    <code>zipWith</code> es la forma de dos fuentes y, a diferencia de la
    estática basada en listas, puede emparejar tipos <em>distintos</em>.
  </p>
  <p>
    Merece la pena poner <code>zip</code> y
    <code><a href="combineLatest.html">combineLatest</a></code> uno al lado
    del otro, porque son las dos mitades de «combinar dos streams» y la gente
    echa mano del equivocado constantemente. <strong>zip empareja por
    posición</strong>: el 3.º de A siempre se encuentra con el 3.º de B, tarde
    lo que tarde. <strong>combineLatest empareja por tiempo</strong>:
    cualquier evento vuelve a emitir con lo que el otro lado tenga en ese
    momento, así que una fuente puede aparecer en muchas salidas y otra en
    ninguna. <code>combineLatestAll</code> es su forma N-aria.
  </p>
  <p>
    Los demás son secuenciación más que combinación.
    <code>FxEvents.concat</code> reproduce cada fuente hasta el final antes de
    empezar la siguiente; <code>followedBy</code> es su forma de dos fuentes,
    llamada así por el propio <code>Iterable.followedBy</code> de Dart.
    <code>mergeWith</code> y <code>raceWith</code> son las formas de instancia
    de <code><a href="race.html">FxEvents.merge</a></code> y
    <code><a href="race.html">FxEvents.race</a></code>. Capa de eventos de
    fxdart, siguiendo a <code>forkJoin</code>, <code>zip</code>,
    <code>combineLatestList</code> y <code>concat</code> de Rx.
  </p>

  <h2>Demo 1 · Esperar a cada panel</h2>
  {{playground:0}}

  <h2>Demo 2 · Por posición o por tiempo</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: secuenciación — concat, followedBy, raceWith, mergeWith.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — el emparejado por tiempo, y el que normalmente quieres para el estado de la UI ·
    <a href="race.html"><code>race</code></a> — gana la primera fuente que habla, las demás se cancelan ·
    <a href="zip.html"><code>zip</code></a> — el original de la capa pull, que empareja Iterables por índice
  </div>
