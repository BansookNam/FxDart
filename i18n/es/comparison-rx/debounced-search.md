---
slug: debounced-search
title: Aplicar debounce al buscador — RxDart vs FxDart
description: Esperar a que el tecleo se calme antes de buscar — un solo operador debounceTime sobre el stream de eventos vs un debouncer de callback cableado a mano.
heading: Aplicar debounce al buscador
order: 40
tier: 4
functions: fx, debounce, toAsync, map
domain: users
verdict: rxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un usuario teclea <code>f</code>, <code>fx</code>, <code>fxd</code>
    en una ráfaga rápida, hace una pausa, y luego teclea
    <code>fxdart</code>. Busca solo cuando el tecleo haya estado en
    silencio 160&nbsp;ms — de modo que corren exactamente dos búsquedas
    (<code>fxd</code> y <code>fxdart</code>) — e imprime cada resultado.
    El calendario de pulsaciones está simulado en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Este es un problema <em>push</em> en su forma más pura: lo
    interesante no son los valores sino <strong>cuándo dejan de
    llegar</strong>. Eso es exactamente lo que un stream modela, y RxDart
    lo dice directamente — <code>debounceTime(160ms)</code> sobre el
    stream de eventos, luego buscar, luego recoger. La suscripción, el
    ventaneo y el borde final al cerrar los maneja todos el operador.
  </p>
  <p>
    FxDart no tiene operadores de pipeline basados en tiempo a propósito
    — un pipeline pull no tiene «tiempo entre llegadas», solo demanda. Su
    <code>debounce</code> es el <em>envoltorio de callback</em> al estilo
    FxTS: correcto, pero lo cableas al stream tú mismo, recoges a mano
    las consultas tranquilas, esperas la ventana final al cerrar, y solo
    entonces entregas las supervivientes a un pipeline tipado para las
    búsquedas de verdad. El veredicto honesto: en este lado del puente,
    usa RxDart — y si el trabajo aguas abajo crece (manejo de errores
    tipado, fetches concurrentes ordenados), pasa el stream con debounce
    por <code>fxStream</code> y continúa en FxDart desde ahí.
  </p>
