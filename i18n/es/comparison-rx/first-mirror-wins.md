---
slug: first-mirror-wins
title: Poner a competir dos mirrors — RxDart vs FxDart
description: Dos mirrors compiten por un payload — Rx.race cancela el fetch perdedor en pleno vuelo; un pipeline pull solo puede negarse a arrancarlo.
heading: Poner a competir dos mirrors
order: 46
tier: 4
functions: fx, toAsync, head
domain: general
verdict: rxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    El mismo payload está disponible desde dos mirrors: el mirror de la
    UE responde en 60&nbsp;ms, el de EE. UU. en 180&nbsp;ms. Obtenlo lo
    más rápido posible y asegúrate de que el fetch lento
    <strong>no</strong> corre hasta completarse — demuéstralo contando
    los fetches completados bien después de la fecha límite del perdedor.
    Los mirrors están simulados en el código como streams cancelables;
    las dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La carrera es una idea push: suscríbete a todo, quédate con quien
    hable primero, <em>cancela</em> el resto. <code>Rx.race</code> es
    exactamente eso — ambos mirrors están genuinamente en vuelo, y en el
    momento en que el mirror de la UE emite a los 60&nbsp;ms la
    suscripción de EE. UU. se cancela, su <code>onCancel</code> se
    dispara, y el temporizador pendiente muere. Por eso el conteo de
    fetches completados sigue siendo 1 mucho después de la fecha límite
    de 180&nbsp;ms del perdedor: el trabajo se detuvo, no solo se ignoró.
  </p>
  <p>
    El lado FxDart imprime las mismas líneas pero <strong>no es una
    carrera</strong>. <code>head</code> demanda un elemento, así que la
    cadena pull escucha solo al primer mirror — al de respaldo nunca se
    le suscribe y nunca arranca. La pereza dirigida por demanda puede
    negarse a <em>arrancar</em> trabajo, pero un pipeline pull no tiene
    manera de cancelar un <code>Future</code> ya en vuelo: si hubiéramos
    arrancado ambos fetches, el perdedor habría corrido hasta completarse
    y simplemente se habría ignorado. Y si el mirror lento hubiera estado
    listado primero, esta cadena sencillamente habría esperado
    180&nbsp;ms, mientras que <code>Rx.race</code> aún habría ganado con
    el respaldo. Cuando el requisito es «gana el primero en responder,
    los perdedores se cancelan», usa el modelo de streams — este es
    terreno de RxDart.
  </p>
