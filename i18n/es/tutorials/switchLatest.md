---
slug: switchLatest
title: switchLatest — FxDart 101
description: Tutorial de switchLatest en FxDart: aplana un stream de streams quedándote solo con el interno más nuevo — más flattenMerge, flattenConcat, exhaustLatest y concatEager — con playground en vivo.
heading: <code>switchLatest</code>, <code>flattenMerge</code> &amp; friends
section: 14
crumb: switchLatest
prev: mergeMap.html
prevLabel: mergeMap
next: mergeScan.html
nextLabel: mergeScan
---
  <p class="hero-sub">Un stream de streams, aplanado: quédate con el más nuevo, ejecútalos todos, reprodúcelos en orden, o ignora los de más — y arranca fuentes posteriores de inmediato con <code>concatEager</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    A veces los eventos ya <em>son</em> streams internos — un socket
    por sesión, una petición ya construida. No hay mapper que escribir;
    la única pregunta es la política de aplanado. Eso es lo que son estas
    formas identidad:
    <code>switchLatest</code> es
    <code><a href="switchMap.html">switchMap</a>((s) =&gt; s)</code>,
    <code>flattenMerge</code> es
    <code><a href="mergeMap.html">mergeMap</a></code>,
    <code>flattenConcat</code> es <code>concatMap</code>,
    <code>exhaustLatest</code> es <code>exhaustMap</code>. Un
    <code>FxEvents</code> de <code>FxEvents</code> se aplana como
    <code>.map((e) =&gt; e.stream).switchLatest()</code>.
  </p>
  <p>
    <code>switchLatest</code> refleja solo el stream interno más nuevo: uno
    fresco <strong>cancela</strong> el anterior en pleno vuelo. Úsalo
    cuando los internos viejos se vuelven inútiles — el feed de la pestaña
    actual, los resultados de la consulta actual. La cadena se cierra cuando el externo se ha cerrado
    <em>y</em> el último interno completa.
  </p>
  <p>
    Los otros tres son el resto de la tabla de políticas.
    <code>flattenMerge</code> ejecuta todos los internos a la vez (acota con
    <code>concurrent: n</code>);
    <code>flattenConcat</code> reproduce cada uno hasta el final antes de que empiece el siguiente;
    <code>exhaustLatest</code> se queda con el primero e ignora
    los internos que llegan mientras uno sigue en marcha.
  </p>
  <p>
    <code>concatEager</code> es el hermano de
    <code><a href="waitAll.html">FxEvents.concat</a></code>. Ambos emiten
    en el orden de la fuente, pero concat espera a <em>suscribirse</em> a la siguiente
    fuente hasta que la actual completa — una fuente posterior fría ni
    siquiera ha arrancado. <code>concatEager</code> se suscribe a todas las
    fuentes de inmediato y almacena en búfer los eventos posteriores hasta que les toca. Así
    es como arrancas una petición ahora y aun así reproduces las respuestas en
    orden. Capa de eventos de fxdart, siguiendo a <code>switchAll</code>,
    <code>mergeAll</code>, <code>concatAll</code>,
    <code>exhaustAll</code> y <code>concatEager</code> de Rx.
  </p>

  <h2>Demo 1 · switchLatest — gana el interno más nuevo</h2>
  {{playground:0}}

  <h2>Demo 2 · flattenConcat frente a switchLatest</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: <code>concatEager</code> frente a concat — las posteriores arrancan de inmediato.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — la forma mapeada de switchLatest ·
    <a href="mergeMap.html"><code>mergeMap</code></a> — mergeMap, concatMap, exhaustMap ·
    <a href="waitAll.html"><code>FxEvents.concat</code></a> — el hermano que se suscribe después de <code>concatEager</code>
  </div>
