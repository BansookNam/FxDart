---
slug: combineLatest
title: combineLatest — FxDart 101
description: Tutorial de combineLatest en FxDart: en cada evento de cualquiera de los dos streams, combina los dos valores más recientes — estado derivado al estilo validación de formularios — con playground en vivo.
heading: <code>combineLatest</code>
section: 14
crumb: combineLatest
prev: sampleOn.html
prevLabel: sampleOn
next: withLatestFrom.html
nextLabel: withLatestFrom
---
  <p class="hero-sub">En cada evento de cualquiera de los dos lados, emite <code>combine</code> de los dos valores más recientes — una vez que ambos lados han hablado al menos una vez.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un formulario es válido cuando el nombre de usuario <em>actual</em> y la
    contraseña <em>actual</em> pasan ambos — dos streams tecleados de forma
    independiente, un estado derivado que debe ser correcto tras cada
    pulsación en cualquiera de los dos.
    <code>combineLatest(other, combine)</code> es esa forma: recuerda el
    último valor de cada lado, y cada evento de <em>cualquiera</em> de los
    streams vuelve a ejecutar <code>combine</code> sobre el par fresco.
  </p>
  <p>
    Las reglas, con precisión. Nada se emite hasta que <strong>ambos</strong>
    lados han producido al menos un valor — no existe el par a medio
    inicializar. A partir de ahí, un evento de entrada produce exactamente
    un evento de salida. Y un lado que se cierra deja de actualizar, pero su
    último valor sigue en juego: el resultado solo se cierra cuando
    <strong>ambos</strong> lados se han cerrado.
  </p>
  <p>
    Elige tu combinador según <em>quién dispara</em>. Si las actualizaciones
    de cualquiera de los dos lados deben re-derivar el estado, este es tu
    operador. Si solo los eventos de la <em>fuente</em> deben disparar — con
    el otro stream meramente consultado por su último valor — eso es
    <code><a href="withLatestFrom.html">withLatestFrom</a></code>.
    Contrasta con el <code><a href="zip.html">zip</a></code> del mundo pull,
    que empareja el <em>n</em>-ésimo con el <em>n</em>-ésimo;
    <code>combineLatest</code> empareja lo más nuevo con lo más nuevo y
    nunca espera a que los índices se alineen. Capa de eventos de fxdart,
    según el operador Rx del mismo nombre.
  </p>

  <h2>Demo 1 · Validación de formulario desde dos campos</h2>
  {{playground:0}}

  <h2>Demo 2 · Un lado cerrado mantiene su última palabra</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: un estado de pantalla a partir de dos sensores.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — unilateral: solo los eventos de la fuente emiten ·
    <a href="zip.html"><code>zip</code></a> — emparejamiento alineado por índice en el mundo pull ·
    <a href="liveValue.html"><code>LiveValue</code></a> — cuando lo que necesitas es el valor actual en sí
  </div>
