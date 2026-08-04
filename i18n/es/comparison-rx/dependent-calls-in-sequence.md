---
slug: dependent-calls-in-sequence
title: Cada llamada alimenta la siguiente — RxDart vs FxDart
description: Cuatro llamadas a la API donde cada respuesta siembra la petición siguiente — scan enhebra el estado por el pipeline; asyncMap se cierra sobre un token mutable.
heading: Cada llamada alimenta la siguiente
order: 49
tier: 4
functions: fx, toAsync, map, scan
domain: general
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Cuatro pasos de API corren estrictamente uno tras otro — login,
    perfil, pedidos, factura — y cada petición se construye a partir de
    la <strong>respuesta anterior</strong> (el id de sesión alimenta la
    llamada de perfil, el id de usuario alimenta la llamada de pedidos,
    …). Imprime cada paso con su respuesta. La tabla de la API falsa está
    en el código; las dos versiones deben imprimir las líneas que
    aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ningún modelo tiene que pelear aquí por la secuencialidad. El
    <code>asyncMap</code> de RxDart pausa la fuente mientras corre cada
    future, así que las llamadas son seriales por construcción; un
    pipeline pull solo pide el siguiente valor después de que el anterior
    se resolviera, así que es serial por defecto. La diferencia
    interesante es dónde vive la <em>dependencia</em> — el token que cada
    respuesta entrega a la petición siguiente.
  </p>
  <p>
    El lado RxDart lo enhebra por una variable mutable sobre la que el
    mapper se cierra: idiomático, compacto, y ligeramente fuera del
    pipeline — el flujo de datos entre pasos es invisible para la cadena
    de operadores. El lado FxDart lo enhebra por el acumulador de
    <code>scan</code>, de modo que la respuesta anterior es una entrada
    explícita del paso siguiente; el coste es que <code>scan</code> emite
    su semilla, que la impresión tiene que saltarse. Una variable oculta
    frente a una línea de semilla saltada — un empate genuino, decidido
    por si prefieres el estado capturado en un closure o el estado
    visible en el pliegue.
  </p>
