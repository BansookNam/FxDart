---
slug: mapEither
title: mapEither — FxDart 101
description: Tutorial de mapEither en FxDart: ejecuta cada evento en un ámbito Raise de modo que un raise se convierte en Left y un return en Right, con un gemelo async — con playground en vivo.
heading: <code>mapEither</code> &amp; <code>mapEitherAsync</code>
section: 14
crumb: mapEither
prev: attempt.html
prevLabel: attempt
next: separated.html
nextLabel: separated
---
  <p class="hero-sub">Ejecuta cada evento en su propio ámbito raise: <code>r.raise</code> (y <code>r.ensure</code> / <code>r.bind</code>) se convierte en un <code>Left</code>, un retorno normal en un <code>Right</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="attempt.html">attempt</a></code> es la conversión de
    frontera — convierte lo que ya está en el canal de error en
    un <code>Left</code>. <code>mapEither</code> es el operador al que
    llegas <em>después</em> de eso, o sobre una fuente limpia: cada evento
    corre dentro de un constructor <code><a href="raise.html">either</a></code>,
    así que escribes Dart en línea recta con <code>r.ensure</code> /
    <code>r.raise</code> y el resultado del map entero es
    <code>Either&lt;E, R&gt;</code>. Un evento que falla no cancela
    la fuente; los eventos posteriores siguen llegando.
  </p>
  <p>
    Una excepción <em>lanzada</em> se queda en el canal de error — ese es el
    contrato del constructor <code>either</code>, y mantiene
    a <code>attempt</code> como el único sitio donde un throw se convierte en un
    valor. Cuando un callback tanto eleva como lanza, prefiere
    <code>eitherCatching</code> dentro de <code>mapEither</code> para que salga un
    <code>Either</code>.
  </p>
  <p>
    <code>mapEitherAsync</code> es el gemelo async: un evento a la vez,
    como <code>asyncMap</code>. La regla de <code>eitherAsync</code> se
    conserva: un raise debe ocurrir dentro de la cadena awaited. Un raise desde un
    future no awaited sobrevive al ámbito y aparece como un error de zona
    no manejado en vez de un <code>Left</code>.
  </p>
  <p>
    Un error de la fuente atraviesa ambos operadores intacto. Conviértelos
    con <code>attempt</code> aguas arriba cuando también los quieras como
    <code>Left</code>s.
  </p>

  <h2>Demo 1 · Un raise se convierte en Left, un return en Right</h2>
  {{playground:0}}

  <h2>Demo 2 · mapEitherAsync, un evento a la vez</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: una excepción lanzada se queda en el canal de error, y la
    cadena continúa más allá de ella.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="attempt.html"><code>attempt</code></a> — la frontera que convierte un throw en un <code>Left</code> ·
    <a href="raise.html"><code>either</code> constructor</a> — el mismo ámbito raise, sobre un solo valor ·
    <a href="separated.html"><code>rights</code> / <code>separated</code></a> — parte los <code>Either</code>s resultantes
  </div>
