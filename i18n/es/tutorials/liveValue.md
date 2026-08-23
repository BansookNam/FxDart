---
slug: liveValue
title: LiveValue — FxDart 101
description: Tutorial de LiveValue en FxDart: un valor actual con suscriptores — los que llegan tarde reciben primero la repetición del último valor y luego las actualizaciones en vivo — con playground en vivo.
heading: <code>LiveValue</code>
section: 14
crumb: LiveValue
prev: shareReplay.html
prevLabel: shareReplay
next: fxSubscriptions.html
nextLabel: FxSubscriptions
---
  <p class="hero-sub">Un «valor actual» vivo con suscriptores: un suscriptor tardío recibe de inmediato el último valor, y después cada actualización posterior.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un <code>Stream</code> normal no tiene memoria: suscríbete tarde y no
    recibes nada hasta el siguiente evento, lo que para el estado — el
    usuario actual, la temperatura actual, el zoom actual — significa que
    cada pantalla nueva arranca en blanco. <code>LiveValue&lt;T&gt;</code>
    es el estado hecho fuente de eventos: guarda un valor actual,
    <code>add</code> lo actualiza y notifica a los suscriptores, y todo
    <strong>suscriptor tardío recibe primero la repetición del último
    valor</strong> y luego se sube a las actualizaciones en vivo. Sin hueco,
    sin arranque en blanco, sin «espera al siguiente tic».
  </p>
  <p>
    La API es deliberadamente pequeña. Construye vacío
    (<code>LiveValue()</code>) o con semilla
    (<code>LiveValue.seeded(value)</code>). Lee de forma síncrona con
    <code>.value</code> — que lanza un <code>StateError</code> cuando no se
    ha establecido nada, así que comprueba <code>.hasValue</code> o siembra
    el valor; no hay un <code>null</code> silencioso haciéndose pasar por
    estado. Suscríbete a través de <code>.live</code>, que es una cadena
    <code><a href="fxEvents.html">FxEvents</a></code> (mapéala, aplícale
    debounce, combínala), o de <code>.stream</code> para la vista de
    Stream normal del mismo feed.
  </p>
  <p>
    <code>close()</code> termina el feed: los streams de los suscriptores
    se cierran, y un <code>add</code> posterior lanza — aunque incluso un
    <code>LiveValue</code> cerrado sigue repitiendo su último valor a un
    suscriptor tardío antes de cerrarle el stream. Si conoces Rx, esto es
    <code>BehaviorSubject</code> reducido a su comportamiento definitorio;
    capa de eventos de fxdart, no parte de FxTS.
  </p>

  <h2>Demo 1 · Los suscriptores tardíos arrancan desde el último valor</h2>
  {{playground:0}}

  <h2>Demo 2 · value, hasValue y close</h2>
  {{playground:1}}

  <h2>La forma con método</h2>
  <p>
    Un <code>Stream</code> alcanza ambos constructores como miembros:
    <code>source.fxLive</code> es <code>LiveValue.from(source)</code>, y
    <code>source.fxLiveSeeded(v)</code> es
    <code>LiveValue.seededFrom(v, source)</code>. Los dos siguen siendo
    calientes: la suscripción se abre en el acto.
  </p>
  <pre><code>final price = ticker.fxLive;
final count = taps.fxLiveSeeded(0);   // has a value before the first tap</code></pre>
  <h2>Pruébalo tú</h2>
  <p>Ejercicio: deriva un feed de etiquetas desde estado en vivo.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>.live</code> habla esta cadena de forma nativa ·
    <a href="combineLatest.html"><code>combineLatest</code></a> — derivar estado desde dos feeds vivos ·
    <a href="streams.html">Puentes de Stream</a> — llevar el feed al mundo pull
  </div>
