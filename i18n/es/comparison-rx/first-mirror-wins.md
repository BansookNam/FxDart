---
slug: first-mirror-wins
title: Poner a competir dos mirrors — RxDart vs FxDart
description: Dos mirrors compiten por un payload — Rx.race y FxEvents.race cancelan ambos el fetch perdedor en pleno vuelo, y ambos lo demuestran con un solo fetch completado.
heading: Poner a competir dos mirrors
order: 46
tier: 4
functions: fxEvents, race
domain: general
verdict: tie
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
    Ya no difieren. La carrera es una idea push — suscríbete a todo,
    quédate con quien hable primero, <em>cancela</em> el resto — y desde
    fxdart 0.8.0 <code>FxEvents.race</code> es exactamente eso,
    igualando a <code>Rx.race</code> movimiento a movimiento: ambos
    mirrors están genuinamente en vuelo, y en el momento en que el
    mirror de la UE emite a los 60&nbsp;ms la suscripción de EE. UU. se
    cancela, su <code>onCancel</code> se dispara, y el temporizador
    pendiente muere. Ambos paneles lo demuestran de la misma manera — el
    conteo de fetches completados sigue siendo 1 mucho después de la
    fecha límite de 180&nbsp;ms del perdedor. El trabajo se detuvo, no
    solo se ignoró, en ambos lados.
  </p>
  <p>
    El viejo panel FxDart solo podía negarse a <em>arrancar</em> el
    fetch de respaldo; la capa de eventos absorbió en cambio el enfoque
    Rx: una cadena envoltorio fina sobre <code>Stream</code>s llanos que
    no colisiona con nada, rxdart incluido. El catálogo de operadores de
    RxDart sigue siendo mucho más amplio — fxdart mantiene pequeño el
    núcleo de eventos y entrega el procesamiento por valor del ganador
    al lado pull tipado vía <code>.pull()</code>. Para «gana el primero
    en responder, los perdedores se cancelan», los dos son ahora
    equivalentes operador por operador: empate.
  </p>
