---
slug: onChange
title: onChange — FxDart 101
description: Tutorial de onChange en FxDart: envuelve un callback para que solo se ejecute cuando cambia su argumento — uniqAdjacent para un callback — con playground en vivo.
heading: <code>fxOnChange</code>
section: 12
crumb: onChange
prev: throttle.html
prevLabel: throttle
next: conflate.html
nextLabel: conflate
---
  <p class="hero-sub">Ejecuta un callback solo cuando su argumento difiere del último — <code>uniqAdjacent</code>, para una función.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un valor consultado con un temporizador o recalculado en cada frame — un
    segundo transcurrido leído cuatro veces por segundo, un contador de
    monedas, una fracción de progreso — llega con mucha más frecuencia de la
    que cambia. La guarda es siempre las mismas tres líneas: recordar el
    último valor, comparar, retornar antes de tiempo.
    <code>fxOnChange(f)</code> es esas líneas, escritas una sola vez. La
    primera llamada siempre se ejecuta; a partir de ahí, una llamada ejecuta
    <code>f</code> solo cuando su argumento no es igual al argumento de la
    última llamada que sí lo hizo.
  </p>
  <p>
    La igualdad es <code>==</code> por defecto; pasa <code>equals</code> para
    decidir qué significa «cambió» — un tramo de redondeo, un campo de un
    record, un string sin distinguir mayúsculas. <code>.reset()</code> olvida
    el último valor, así que la siguiente llamada se ejecuta con lo que traiga.
    Igual que <a href="debounce.html"><code>fxDebounce</code></a>, tiene una
    forma con método sobre el callback: <code>setCoins.fxOnChange()</code>.
  </p>
  <p>
    Es el gemelo para callbacks de
    <code><a href="uniqAdjacent.html">uniqAdjacent</a></code>: la misma regla,
    para un valor empujado a una función en lugar de extraído de una
    secuencia. A diferencia de un debounce, no añade retraso y no descarta
    nada que haya cambiado. Extensión de fxdart (sin contraparte en FxTS).
  </p>

  <h2>Demo 1 · Un valor consultado periódicamente</h2>
  {{playground:0}}

  <h2>Demo 2 · equals y reset()</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: deja de escribir un contador de monedas que no cambió.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="uniqAdjacent.html"><code>uniqAdjacent</code></a> — la misma regla sobre una secuencia ·
    <a href="debounce.html"><code>fxDebounce</code></a> — espera a que todo se calme ·
    <a href="throttle.html"><code>fxThrottle</code></a> — como mucho una vez por ventana ·
    <a href="memoizeLast.html"><code>fxMemoizeLast</code></a> — evita recalcular para la misma entrada
  </div>
