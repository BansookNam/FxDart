---
slug: whenComplete
title: whenComplete — FxDart 101
description: Tutorial de whenComplete en FxDart: echa un vistazo a un efecto secundario, handleError sin cambiar de stream, finalize al terminar o cancelar — y quédate en la cadena FxEvents — con playground en vivo.
heading: <code>peek</code>, <code>whenComplete</code> &amp; <code>handleError</code>
section: 14
crumb: whenComplete
prev: fxEventsCreate.html
prevLabel: fxEventsCreate
next: sampleOn.html
nextLabel: sampleOn
---
  <p class="hero-sub">Efectos secundarios, continuar por error, y un gancho de finalize — sin bajarte de la cadena a <code>.stream</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    El <code><a href="peek.html">peek</a></code> de la capa pull observa
    valores a medida que se tiran. El
    <code>peek</code> de la capa de eventos es la misma palabra para la misma idea en un stream
    push: ejecuta un efecto secundario, deja pasar el evento sin cambios.
    Los ganchos opcionales <code>onError</code> / <code>onDone</code> cubren las
    otras dos notificaciones. Un callback que lanza se convierte en un evento de
    error y la cadena continúa — el evento cuyo peek falló
    no se reemite. Capa de eventos de fxdart, siguiendo a <code>tap</code> /
    <code>doOn*</code> de Rx.
  </p>
  <p>
    <code>handleError</code> es la forma por-error-y-continuar:
    los errores que coinciden (todos los errores cuando se omite <code>test</code>)
    ejecutan <code>onError</code> y el stream sigue adelante. Eso no es
    <code><a href="onErrorResume.html">onErrorResume</a></code>, que
    cancela la fuente y cambia. Usa handleError para registrar o
    tragar un fallo puntual; usa onErrorResume para abandonar la
    conexión. <code>whenComplete</code> es el
    <code>finalize</code> de Rx: el callback se ejecuta
    <strong>exactamente una vez</strong>, al terminar, ante un error, o al cancelar.
    Aunque lance, la cadena igual se desmonta.
  </p>
  <p>
    La cadena ya no baja a <code>.stream</code> para
    <code>endWith</code>, <code>ifEmpty</code>, <code>uniq</code>,
    <code>takeRight</code>, <code>takeWhile</code> tampoco — ahora son
    métodos de <code>FxEvents</code>. <code>uniq</code> es global
    (no adyacente): el conjunto de vistos crece sin límite, así que un feed de larga
    vida más un <code>uniq</code> ilimitado es una fuga de memoria; prefiere
    <code>uniqAdjacent</code> cuando solo deban eliminarse las
    repeticiones consecutivas.
  </p>
  <p>
    Capa de eventos de fxdart, siguiendo a <code>tap</code>,
    <code>catchError</code> en su forma que no cambia de stream, y
    <code>finalize</code> de Rx. Los nombres de la capa pull ganan donde ya
    significan lo mismo: <code>peek</code> no <code>tap</code>,
    <code>takeRight</code> no <code>takeLast</code>,
    <code>uniq</code> no <code>distinct</code>.
  </p>

  <h2>Demo 1 · peek como efecto secundario</h2>
  {{playground:0}}

  <h2>Demo 2 · endWith, e ifEmpty</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: <code>whenComplete</code> al terminar, y al cancelar.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="peek.html"><code>peek</code></a> — el original de la capa pull, que observa valores a medida que se tiran ·
    <a href="onErrorResume.html"><code>onErrorResume</code></a> — abandonar y cambiar; <code>handleError</code> es la forma que continúa ·
    <a href="tap.html"><code>tap</code></a> — efecto secundario data-first sobre un solo valor, no un stream
  </div>
