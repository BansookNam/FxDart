---
slug: recent-errors
title: Mensajes de error recientes, sin duplicados — Dart vs FxDart
description: Los tres errores distintos más recientes de un log ordenado de más nuevo a más antiguo — un bucle con un Set de vistos y un break en Dart nativo frente a filter + uniqBy + take en FxDart.
heading: Mensajes de error recientes, sin duplicados
order: 12
tier: 2
functions: filter, uniqBy, take
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
    convierte en un bucle con tres asuntos trenzados: la comprobación del
    nivel, el truco del <code>seen.add</code> y un <code>break</code> con
    contador. Cada uno por separado está bien; juntos te obligan a leer el
    bucle entero para ver qué es lo que conserva. FxDart enuncia las tres
    reglas como tres pasos de la cadena —<code>filter</code>,
    <code>uniqBy</code>, <code>take</code>— y, como la cadena es perezosa,
    también deja de recorrer el log en el momento en que encuentra el
    tercer error distinto, exactamente igual que el <code>break</code>
    escrito a mano.
  </p>
