---
slug: namingOfTypedErrors
title: Por qué «errores tipados» (y no Monad) — FxDart 101
description: Las razones del nombre detrás de los errores tipados de FxDart: por qué la guía no se llama Monad, por qué se eligió el vocabulario de Arrow y por qué se reservó raise.
heading: ¿Por qué se llama «errores tipados»?
section: 13
crumb: naming
---
  <p class="hero-sub">
    La funcionalidad que hay detrás de <code>either</code> tiene nombres
    famosos en otros ecosistemas: <a href="monad.html"><em>mónada</em></a>,
    <em>railway-oriented programming</em>. Esta página explica por qué FxDart
    ha decidido deliberadamente no llamarla de ninguna de esas maneras. (¿No
    te has cruzado nunca con una mónada? Empieza por
    <a href="monad.html">Mónadas &amp; bloques de comprensión</a>.)
  </p>

  <h2>¿Por qué no «mónada»?</h2>
  <p>
    Porque describiría mal la funcionalidad. Toda la gracia del diseño de
    <code>Raise</code> es que <em>no</em> es estilo monádico: existe para
    <strong>sustituir</strong> el encadenado con <code>flatMap</code> por
    código en línea recta. Ya lo viste en la
    <a href="typedErrors.html">página de errores tipados</a>: el bloque
    <code>either((r) { ... })</code> es la alternativa a la pirámide anidada
    de <code>flatMap</code>, no una envoltura sobre ella.
  </p>
  <p>
    Arrow, la librería de Kotlin —el origen del diseño de esta
    funcionalidad—, pasó exactamente por esta misma decisión. Arrow 1.x tenía
    una typeclass <code>Monad</code>, emulación de tipos de orden superior y
    todo el vocabulario de Haskell que va con ello. Arrow 2.x
    <strong>lo eliminó todo</strong>, e incluso renombró la operación
    principal <code>shift</code> → <code>raise</code> mediante una votación de
    la comunidad: eligió la palabra que entendían sus usuarios por encima de
    la palabra que usaba la teoría. La lección se generaliza: pon nombres
    pensando en el público que quieres, y el público de FxDart son
    desarrolladoras y desarrolladores de Dart normales, no teóricos de
    categorías.
  </p>
  <p>
    En el propio Dart hay además un aviso a navegantes: las librerías de FP
    cuya superficie pública habla Haskell (<code>Monad2</code>,
    <code>HKT</code>, notación <code>Do</code>) intimidan justo a quienes más
    partido sacarían de los errores tipados. Una página titulada «Monad»
    espantaría a sus propios lectores, y encima describiría precisamente lo
    único que esta API no es.
  </p>

  <h2>¿Por qué «errores tipados»?</h2>
  <ul>
    <li><strong>Dice lo que hace la funcionalidad</strong> — errores que viajan
      en el sistema de tipos en lugar de lanzarse por encima de él —, en vez
      de decir cómo llama la teoría de categorías a esa forma.</li>
    <li><strong>Es el nombre que usa Arrow.</strong> El capítulo
      correspondiente de la documentación de Arrow se titula literalmente
      <em>Typed errors</em>, así que quien programa en Kotlin y busca el
      equivalente en Dart aterriza en las palabras correctas.</li>
    <li><strong>Sigue la norma de la casa.</strong> La filosofía de
      nomenclatura de FxDart (ver <code>WHY_CURRIED.md</code>: «porta el
      significado, no la grafía») es: nombres de Dart, no nombres de Haskell
      — <code>map</code> y no <code>fmap</code>, <code>flatMap</code> y no el
      verbo <code>bind</code>, <code>recover</code> y no
      <code>handleErrorWith</code>.</li>
  </ul>

  <h2>¿Por qué no «raise»?</h2>
  <p>
    <code>raise</code> es el nombre «molón» y además exacto: es como se llama
    de verdad el DSL, y aquí las URL de los tutoriales llevan nombre de
    función (<code>concurrent.html</code>, <code>fx.html</code>). Se reservó a
    propósito: si la sección&nbsp;13 gana más adelante páginas de tutorial por
    función (<code>either.html</code>, <code>bind.html</code>, …), un resumen
    en <code>raise.html</code> chocaría con el futuro tutorial de la función
    <code>raise</code>. <code>typedErrors.html</code> queda libre para siempre
    como página de resumen de la sección.
  </p>

  <h2>¿Y «railway»?</h2>
  <p>
    <em>Railway-oriented programming</em> es una metáfora muy conocida para la
    misma idea (una vía de éxito y una vía de fallo). Es un modelo mental
    estupendo… y un mal nombre de página: se busca peor, no es vocabulario de
    Arrow y es una metáfora que ya tienes que conocer antes de que te sirva de
    algo.
  </p>

  <div class="callout">
    <strong>El principio en una línea.</strong> Un nombre forma parte de la
    API: debería decirle a quien programa en Dart qué hace esa cosa, con las
    palabras que buscaría — <em>errores tipados</em> —, no certificar qué
    abstracción es en secreto.
  </div>
