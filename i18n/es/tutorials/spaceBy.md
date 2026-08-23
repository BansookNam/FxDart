---
slug: spaceBy
title: spaceBy — FxDart 101
description: Tutorial de spaceBy en FxDart: dosifica una ráfaga sin perder nada, desplaza un stream con delay y lee el valor más reciente por reloj con sample — con playground en vivo.
heading: <code>delay</code>, <code>spaceBy</code> &amp; <code>sample</code>
section: 14
crumb: spaceBy
prev: groupsBy.html
prevLabel: groupsBy
next: debounceOn.html
nextLabel: debounceOn
---
  <p class="hero-sub">Tres formas de mover eventos en el tiempo: desplazarlos todos, separarlos, o leer solo el más reciente a un ritmo fijo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Limitar el ritmo siempre te cuesta algo, y la única pregunta real es
    <em>qué</em>. <code><a href="throttle.html">throttle</a></code> y
    <code><a href="debounce.html">debounce</a></code> pagan en
    <strong>eventos</strong>: se quedan con uno por ventana y descartan el
    resto, lo cual es correcto cuando los eventos son muestras de algo
    continuo y uno viejo no vale nada. <code>spaceBy(gap)</code> paga en
    <strong>tiempo</strong>: todos los eventos sobreviven, encolados y
    liberados uno por <code>gap</code>, lo cual es correcto cuando cada
    evento es una instrucción discreta que no puedes perder — seis mensajes
    que enviar contra una API que permite una llamada cada 100 ms.
  </p>
  <p>
    Ese intercambio tiene un filo. Como <code>spaceBy</code> encola en vez de
    descartar, una fuente que produzca más rápido que <code>gap</code>
    indefinidamente hace crecer una cola sin límite. Es para
    <em>ráfagas</em> —un lote que llega de golpe y tiene que pasar entero—, no
    para una entrada genuinamente interminable, donde perder eventos es
    justamente la virtud de throttle.
  </p>
  <p>
    <code>delay(duration)</code> es el más simple de los tres: el stream
    entero se desplaza una cantidad fija, con su separación intacta y sin
    descartar nada. El cierre espera a que aterrice el último evento
    retrasado, así que no se pierde nada al final; los errores se reenvían de
    inmediato, ya que solo los datos merecen retenerse.
  </p>
  <p>
    <code>sample(period)</code> es
    <code><a href="sampleOn.html">sampleOn</a></code> con el reloj
    incorporado: el valor más reciente cada <code>period</code>, en silencio
    cuando no ha llegado nada nuevo. Échale mano cuando la fuente sea un feed
    con aire de estado (una posición, una temperatura, un desplazamiento de
    scroll) y el consumidor tenga su propia tasa de refresco. Capa de eventos
    de fxdart, siguiendo a <code>delay</code>, <code>interval</code> y
    <code>sampleTime</code> de Rx.
  </p>

  <h2>Demo 1 · Dosificar una ráfaga sin pérdidas</h2>
  {{playground:0}}

  <h2>Demo 2 · Desplazar, y leer por reloj</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: un ritmo de envío y un ritmo de informe, en una sola cadena.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="throttle.html"><code>throttle</code></a> — la contraparte con pérdidas: un evento por ventana, de inmediato ·
    <a href="debounce.html"><code>debounce</code></a> — espera a que acabe la ráfaga y toma su último valor ·
    <a href="chunkOn.html"><code>chunkEvery</code></a> — también conserva todos los eventos, pero agrupados en vez de separados
  </div>
