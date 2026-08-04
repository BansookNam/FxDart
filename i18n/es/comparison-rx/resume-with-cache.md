---
slug: resume-with-cache
title: Reanudar desde la caché cuando la fuente muere — RxDart vs FxDart
description: El feed en vivo muere tras tres actualizaciones — onErrorResumeNext conmuta a la cola cacheada frente a un bucle de pull explícito que alimenta concat.
heading: Reanudar desde la caché cuando la fuente muere
order: 34
tier: 3
functions: fx, concat, take, map
domain: orders
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    El feed de pedidos en vivo entrega tres actualizaciones y entonces la
    conexión muere. El panel sigue necesitando sus primeras
    <strong>seis</strong> filas: conserva todo lo que el feed en vivo
    alcanzó a entregar y continúa después desde la instantánea cacheada de
    anoche, marcando esas filas con <code>(from cache)</code>. El fallo se
    inyecta de forma determinista en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Este es el canal de errores en su mejor momento. El punto de
    recuperación es <em>de stream completo</em> — «cuando esta fuente
    muera, cambia a aquella otra para el resto de la secuencia» — que es
    exactamente la forma que un canal de errores push modela.
    <code>onErrorResumeNext</code> dice el requisito entero en un solo
    operador: los valores pasan intactos, y el primer error conmuta la
    suscripción al stream de recuperación en pleno vuelo, con las tres
    actualizaciones entregadas ya a salvo.
  </p>
  <p>
    El lado pull no tiene ningún operador que conserve los valores de una
    fuente que después lanza — un pipeline pull hace aflorar el error en
    el punto del pull, y un <code>toList</code> fallido descartaría lo que
    vino antes. Así que la frontera se escribe a mano: un bucle
    <code>await for</code> recoge las filas en vivo, el
    <code>try</code>/<code>catch</code> pone nombre al fallo, y
    <code>concat</code> + <code>map</code> + <code>take</code> empalman la
    cola cacheada. Dos o tres líneas honestas más — la misma recuperación,
    menos la palabra del vocabulario.
  </p>
  <p>
    Un empate, inclinado hacia RxDart en elegancia aquí. Ambos lados se
    detienen en seis filas, y ninguno lee la caché más allá de lo que la
    página necesita: <code>take</code> cancela la suscripción en un lado y
    simplemente deja de tirar en el otro.
  </p>
