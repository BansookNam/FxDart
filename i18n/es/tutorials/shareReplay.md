---
slug: shareReplay
title: shareReplay — FxDart 101
description: Tutorial de shareReplay en FxDart: ReplayValue y CompletionValue, más el shareReplay connectable que deja a los oyentes tardíos ver el historial — con playground en vivo.
heading: <code>shareReplay</code>, <code>ReplayValue</code> &amp; <code>CompletionValue</code>
section: 14
crumb: shareReplay
prev: share.html
prevLabel: share
next: liveValue.html
nextLabel: LiveValue
---
  <p class="hero-sub">Multicast que recuerda: un búfer de replay acotado, un último valor al cerrar, y el operador de cadena que envuelve una fuente con ambos.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="share.html">share</a></code> difunde una sola ejecución a
    muchos oyentes y después olvida. Un oyente que llega después de que un
    evento haya pasado se lo ha perdido. <code>ReplayValue</code> es el
    subject que recuerda: <code>add</code> añade a un búfer
    recortado por <code>size</code> (por defecto 1; <code>null</code> es
    ilimitado) y <code>maxAge</code>, y cada
    <strong>suscriptor tardío reproduce primero el búfer retenido</strong>,
    y después se sube a las actualizaciones en vivo. Los errores no se
    retienen. Tras
    <code>close</code>, un oyente tardío sigue recibiendo el búfer, y luego
    el cierre. Capa de eventos de fxdart, siguiendo al
    <code>ReplaySubject</code> de Rx.
  </p>
  <p>
    <code>CompletionValue</code> es la otra memoria:
    <code>add</code> solo recuerda, y el último valor se emite
    <strong>al cerrar</strong> — nada mientras está abierto, luego ese valor
    y el cierre. Un oyente tardío tras el cierre recibe lo mismo. Un
    <code>addError</code> completa de inmediato con el error, no con un
    valor recordado. El <code>AsyncSubject</code> de Rx.
    <code><a href="liveValue.html">LiveValue</a></code>, a continuación, es el
    subject de valor actual con una lectura síncrona
    <code>.value</code> — un ReplayValue de tamaño 1 sin el
    getter.
  </p>
  <p>
    <code>connectable()</code> es la forma manual: devuelve un
    <code>ConnectableEvents</code> cuyo feed <code>events</code> no
    suscribe la fuente hasta <code>connect()</code>.
    Los oyentes enganchados de antemano esperan; los oyentes tardíos se pierden los valores ya
    emitidos. <code>refCount()</code> conecta con el primer
    oyente y desconecta con el último, reconectando cuando la
    fuente permite un segundo listen. <code>shareReplay</code> es la
    forma habitual: multicast a través de un <code>ReplayValue</code>,
    conexión en el primer oyente, oyentes tardíos ven el historial.
    <code>resetOnCancel</code> (por defecto <code>true</code>) arranca un
    búfer fresco cuando el último oyente se va;
    <code>false</code> deja la fuente conectada para siempre.
  </p>
  <p>
    Capa de eventos de fxdart, siguiendo a <code>ReplaySubject</code>,
    <code>AsyncSubject</code>, <code>ConnectableObservable</code>
    y <code>shareReplay</code> de Rx.
  </p>

  <h2>Demo 1 · Un suscriptor tardío ve el búfer</h2>
  {{playground:0}}

  <h2>Demo 2 · CompletionValue emite al cerrar</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: <code>shareReplay</code> sobre un <code>fromIterable</code>, dos oyentes.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="share.html"><code>share</code></a> — multicast sin memoria; los oyentes tardíos se pierden lo que ya pasó ·
    <a href="liveValue.html"><code>LiveValue</code></a> — el subject de valor actual, con un <code>.value</code> síncrono ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — el <code>.live</code> de estos subjects es esa cadena
  </div>
