---
slug: recent-errors
title: Mensajes de error recientes, sin duplicados — Dart vs FxDart
description: Los tres errores distintos más recientes de un log ordenado de más nuevo a más antiguo — un bucle con un Set de vistos y un break en Dart nativo frente a filter + uniqBy + take en FxDart.
heading: Mensajes de error recientes, sin duplicados
order: 20
tier: 2
functions: filter, uniqBy, take, takeUniqBy
domain: logs
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Un almacén de logs devuelve las entradas de más nueva a más antigua.
    Muestra los <strong>tres mensajes de error distintos más
    recientes</strong>: quédate solo con las entradas <code>ERROR</code>,
    descarta las repeticiones de un mensaje ya mostrado y detente después
    de tres. Los datos están en el código de abajo; ambas versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart no tiene un «distinto por clave»: deduplicar por mensaje significa
    gestionar tú mismo un <code>Set</code>, así que la versión nativa se
    convierte en un bucle con tres responsabilidades entrelazadas: la comprobación del
    nivel, el truco del <code>seen.add</code> y un <code>break</code> con
    contador. Cada uno por separado está bien; juntos te obligan a leer el
    bucle entero para ver qué es lo que conserva. FxDart enuncia las tres
    reglas como tres pasos de la cadena —<code>filter</code>,
    <code>uniqBy</code>, <code>take</code>— y, como la cadena es perezosa,
    también deja de recorrer el log en el momento en que encuentra el
    tercer error distinto, exactamente igual que el <code>break</code>
    escrito a mano.
  </p>

  <h2>Dos formas de escribirlo en FxDart</h2>
  <p>
    El benchmark de esta página lleva una <strong>tercera barra</strong>, que solo otra página más tiene. La cadena de arriba es la que conviene escribir: tres reglas independientes, leídas de arriba abajo y perezosas —se detiene al encontrar el tercer error distinto, exactamente igual que el <code>break</code> escrito a mano—. Lo que no puede hacer es incorporar (inline) sus propios callbacks. Una etapa perezosa guarda su closure en un campo del iterador, y el compilador AOT no puede ver a través de un campo, así que <code>filter</code> y <code>uniqBy</code> cuestan cada uno una llamada indirecta real por elemento; entre las dos, la mayor parte de lo que separa este pipeline del bucle nativo.
  </p>
  <p>
    <code>takeUniqBy</code>, mostrado encima de <code>main</code> en el panel de FxDart, es el mismo pipeline escrito como una única llamada estricta. Su callback es un <em>parámetro</em> de un cuerpo lo bastante pequeño como para incorporarse en quien lo llama, así que el compilador incorpora el closure junto con él; un solo callback hace ambos trabajos, con una clave <code>null</code> que significa «salta este elemento». Con un millón de líneas de log, esa es la diferencia entre la segunda y la tercera barra; la primera muestra el bucle nativo.
  </p>
  <p>
    Escribe la cadena por defecto. Recurre a <code>takeUniqBy</code> cuando el pipeline sea caliente y un perfil indique que estos callbacks son el coste.
  </p>
