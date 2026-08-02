---
slug: backoff-retry
title: Reintentar con backoff creciente — RxDart vs FxDart
description: Alargar la espera entre intentos — retryWhen mapea cada error a un stream de temporizador a mano frente a un hook delay que devuelve un Duration.
heading: Reintentar con backoff creciente
order: 28
tier: 3
functions: fx, retry
domain: general
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    El servicio de tarifas no está disponible exactamente dos veces, y
    luego sirve. Reintenta con <strong>backoff creciente</strong> — espera
    40&nbsp;ms tras el primer fallo, 80&nbsp;ms tras el segundo — con un
    presupuesto de tres intentos. Imprime el payload, el conteo de
    intentos y la secuencia de backoff registrada (registrada cuando se
    elige cada espera, así que la salida es determinista). Las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El backoff es donde se rompe la simetría de una-sola-llamada del retry
    simple. El <code>retryWhen</code> de RxDart es un protocolo de
    meta-streams: por cada error, tu fábrica debe devolver un <em>stream
    notificador</em> — emite un valor para disparar el reintento, emite un
    error para rendirte. Así que «espera 40 ms, luego 80 ms» se convierte
    en mapear cada fallo a un stream <code>Rx.timer</code>, y como la
    fábrica solo ve un error a la vez, tanto el conteo de fallos como el
    presupuesto de intentos viven en variables mutables <em>fuera</em>
    del operador. Funciona, y es máximamente general — pero estás
    ensamblando a mano un bucle de reintentos a base de streams.
  </p>
  <p>
    FxDart trata el backoff como lo que es: un número que depende de
    cuántas veces has fallado. El hook <code>delay</code> de
    <code>retry</code> recibe el conteo de fallos (<code>1, 2, …</code>) y
    devuelve un <code>Duration</code> — la política entera es una
    expresión, y el presupuesto es el mismo argumento
    <code>attempts</code> de antes. Nada en esperar entre intentos
    requiere un stream, y el lado pull nunca finge que sí.
  </p>
  <p>
    Veredicto FxDart, por conteo de conceptos: un hook frente a una
    fábrica de streams notificadores, un contador externo y un stream de
    temporizador por fallo.
  </p>
