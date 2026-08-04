---
slug: cursor-lifetime
title: La vida de un cursor alrededor de una lectura — RxDart vs FxDart
description: Abrir un cursor, leer cinco filas, garantizar el cierre — Rx.using alrededor de un stream vs usingAsync alrededor de un pull perezoso, dos ports de una misma idea.
heading: La vida de un cursor alrededor de una lectura
order: 32
tier: 3
functions: fx, using, toAsync, toList
domain: general
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Lee cinco filas del libro de cuentas a través de un cursor de base de
    datos falso cuya vida debe abrazar la lectura: creado cuando la
    lectura empieza, cerrado exactamente una vez después de la última
    fila — y leer tras el cierre lanza, así que el paréntesis soporta
    carga real. Imprime las filas y luego <code>closed:&nbsp;true</code>
    como atestación. El cursor está en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    En su mayor parte no difieren — ambos son ports de la misma idea de
    Rx, y FxDart lo dice: <code>usingAsync</code> llegó
    después del <code>using</code> de Rx. La forma es el mismo paréntesis
    de tres partes: adquirir, usar, liberar. <code>Rx.using</code> crea el
    cursor cuando el stream recibe un listener y llama al liberador cuando
    el stream termina; <code>usingAsync</code> adquiere en el primer
    <em>pull</em> y libera exactamente una vez, tras el pull terminal o
    justo antes de que un error se propague. En ambos, la vida del recurso
    está atada al consumo de la secuencia, no a un scope en el llamador —
    que es justamente el sentido de todo esto.
  </p>
  <p>
    Los bordes muestran el temperamento de cada modelo. El liberador de la
    versión de stream también corre al <em>cancelar la suscripción</em> —
    cancela a mitad de camino y el cursor igualmente se cierra, porque una
    suscripción es un objeto con ciclo de vida propio. La versión pull no
    tiene suscripción: la liberación se dispara al completar o al errar,
    así que un consumidor que <em>abandona</em> el iterador en silencio
    nunca la dispararía — el idioma honesto es acotar el pipeline
    (<code>take</code>, o una fuente finita como esta) para que la
    terminación, y por tanto la liberación, esté garantizada. Aquí la
    lectura es finita y se lleva hasta el final, y ambos lados cierran el
    cursor exactamente una vez, después de la fila cinco.
  </p>
  <p>
    Un empate por diseño: este es el par donde las dos bibliotecas
    coinciden en la abstracción y solo difieren en qué significa «la
    iteración terminó» en su modelo.
  </p>
