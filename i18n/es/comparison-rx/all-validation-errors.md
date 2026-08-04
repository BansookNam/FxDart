---
slug: all-validation-errors
title: Reportar cada error de validación — RxDart vs FxDart
description: Cada regla rota por formulario, no solo la primera — valores de error llanos en una cadena síncrona vs un canal de errores que solo puede llevar un error y cerrarse.
heading: Reportar cada error de validación
order: 25
tier: 3
functions: fx, map, partition
alsoLink: accumulate
domain: users
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Cinco formularios de registro del lote 2026-08 se comprueban contra
    tres reglas (nombre presente, email con <code>@</code>, edad 18+). Un
    formulario puede romper <strong>varias</strong> reglas — reporta cada
    regla rota por formulario, y luego lista los formularios que pasaron.
    Los datos están en el código; las dos versiones deben imprimir las
    líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La validación acumulativa es el trabajo que el canal de errores de Rx
    es estructuralmente incapaz de hacer. Un error de stream lleva
    exactamente un objeto, y emitirlo termina el stream — lanza la
    primera regla rota y ni los demás fallos de ese formulario ni los
    formularios restantes se verán jamás. Cada operador de recuperación
    (<code>onErrorReturn</code>, <code>onErrorResumeNext</code>) está
    construido para esa forma de un-error-y-fin. Así que la versión
    RxDart funcional que se muestra aquí abandona en silencio el canal de
    errores: mapea cada formulario a un registro de sus fallos en el
    canal de <em>datos</em> — y llegados a ese punto el stream aporta un
    <code>main</code> async y un <code>toList</code>, nada más.
  </p>
  <p>
    El lado FxDart es la misma idea sin el envoltorio: los errores son
    valores llanos, así que un <code>map</code> + <code>partition</code>
    síncronos entregan los formularios fallidos (con <em>todos</em> sus
    errores) y los válidos en una sola expresión. Y como FxDart trata los
    errores como valores en todas partes, este patrón escala más allá de
    los registros: la capa de errores tipados acumula por ti —
    <code>zipOrAccumulate</code> ejecuta cada regla y concatena los
    fallos en una <code>NonEmptyList</code>, y
    <code>mapOrAccumulate</code> valida una colección entera fail-slow.
    Mira el tutorial de <code>accumulate</code> para esa versión
    completa; el modelo de streams no tiene contrapartida a la que
    recurrir.
  </p>
