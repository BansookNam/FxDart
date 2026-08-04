---
slug: numbered-checklist
title: Numera la lista de pasos — RxDart vs FxDart
description: Convertir seis pasos en líneas numeradas con 1. — los streams no tienen map con índice, así que Rx cuela un contador a través de scan; fxdart dice zipWithIndex.
heading: Numera la lista de pasos
order: 10
tier: 1
functions: fx, zipWithIndex, map
domain: general
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Convierte seis pasos de instalación en una lista de comprobación
    numerada — <code>1.&nbsp;Unbox the sensor kit</code> y así
    sucesivamente, una línea por paso, numerando desde uno. Los datos
    están en el código; las dos versiones deben imprimir las líneas que
    aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ni el <code>Stream</code> del core ni RxDart tienen un
    <code>map</code> con índice. Lo más cercano que ofrece RxDart es
    <code>scan</code>, cuyo acumulador casualmente recibe un índice como
    tercer argumento — así que la forma rx mostrada numera los pasos
    montándose en un <em>fold</em>: una semilla que tienes que inventar
    (<code>''</code>) y un valor acumulado que ignoras de inmediato. Las
    alternativas no son más limpias en esencia — un contador mutable sobre
    el que cierra el mapper, o hacer zip contra <code>Rx.range</code> —
    todas las rutas cuelan el índice desde fuera, porque ningún operador
    lo lleva consigo. Funciona, y aun así se lee como un apaño.
  </p>
  <p>
    FxDart dice la cosa directamente: <code>zipWithIndex</code> empareja
    cada elemento con su posición, y un <code>map</code> corriente
    formatea la pareja. Esto no es tanto un hueco push-contra-pull como un
    hueco de vocabulario — un operador de emparejado con índice es
    trivialmente expresable en cualquiera de los dos modelos, simplemente
    Rx nunca lo desarrolló — pero el lector de cada panel lo nota: un lado
    declara «elemento con su índice», el otro lo codifica en el parámetro
    sobrante de un acumulador. Veredicto: FxDart.
  </p>
