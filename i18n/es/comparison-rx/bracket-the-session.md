---
slug: bracket-the-session
title: Marcadores de apertura y cierre — RxDart vs FxDart
description: Envolver un feed de sesión en líneas OPEN/CLOSE — startWith y endWith en el stream frente a prepend y append en la cadena pull.
heading: Marcadores de apertura y cierre
order: 18
tier: 2
functions: fx, prepend, append
domain: logs
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Un informe de sesión lista los eventos de un usuario en orden,
    enmarcados por una línea <code>== SESSION OPEN ==</code> antes del
    primer evento y una línea <code>== SESSION CLOSE ==</code> después del
    último. Los cuatro eventos están en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Casi en ningún sitio: esto es paridad de vocabulario. El
    <code>startWith</code> de RxDart inyecta un valor antes de la primera
    emisión de la fuente y <code>endWith</code> inyecta uno después de que
    la fuente se complete; el <code>prepend</code> y el
    <code>append</code> de FxDart son las mismas dos palabras en una
    cadena pull: producen el marcador antes de que el primer tirón llegue
    a la fuente y después de que la fuente se seque. Un operador cada uno,
    nombres simétricos, de primera clase en ambos lados.
  </p>
  <p>
    La única diferencia de modelo que merece notarse es <em>cuándo</em>
    puede existir el marcador de cierre. En el lado push,
    <code>endWith</code> tiene que esperar el evento done — la posición
    del marcador es un hecho sobre el ciclo de vida del stream. En el lado
    pull, <code>append</code> es simplemente lo siguiente que el iterador
    produce una vez agotada la fuente; no hay ciclo de vida que observar,
    solo demanda. Para un feed finito en memoria la distinción es
    invisible, así que este es un empate — elige el modelo en el que ya
    vive el resto de tu pipeline.
  </p>
