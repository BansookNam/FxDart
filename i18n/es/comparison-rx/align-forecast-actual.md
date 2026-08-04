---
slug: align-forecast-actual
title: Alinea el pronóstico con los datos reales — RxDart vs FxDart
description: Emparejar dos series fijas posición a posición e imprimir la diferencia de cada día — zipWith en streams frente a zip en iterables, la misma alineación en ambos casos.
heading: Alinea el pronóstico con los datos reales
order: 20
tier: 2
functions: fx, zip, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Un pronóstico de temperatura a cinco días está junto a lo que el
    sensor midió realmente. Empareja las dos series <strong>posición a
    posición</strong> e imprime una línea por día: pronóstico, real y la
    diferencia con signo a un decimal. Los datos están en el código; las
    dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El emparejado posicional es simétrico entre los modelos y ambas
    bibliotecas lo traen: <code>zipWith</code> combina el enésimo evento
    de un stream con el enésimo de otro, <code>zip</code> empareja los
    enésimos tirones de dos iterables. Ambos se detienen en el lado más
    corto, ambos conservan el orden por construcción. La función de
    formateo se comparte literalmente, así que los paneles difieren solo
    en cómo las dos series se elevan a un pipeline.
  </p>
  <p>
    Los modelos sí esconden maquinaria distinta bajo el nombre compartido.
    El <code>zipWith</code> de stream es un pequeño motor de coordinación:
    dos suscripciones vivas, un búfer de un hueco para el lado que vaya
    por delante, y pausa/reanudación para impedir que un productor rápido
    desborde a uno lento. El <code>zip</code> de iterables son dos
    iteradores avanzados al unísono — el tirón del consumidor <em>es</em>
    la sincronización, así que no hay nada que almacenar y nadie a quien
    pausar. Con dos listas fijas nada de esa maquinaria llega a
    ejercitarse, y exactamente por eso este es un empate: elige la versión
    que coincida con el lugar donde tus series viven de verdad.
  </p>
