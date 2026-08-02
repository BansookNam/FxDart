---
slug: with-latest-config
title: Sellar cada petición con la config más reciente — RxDart vs FxDart
description: Cada petición saliente lleva la versión de config vigente en ese instante — withLatestFrom vs una fusión etiquetada plegada con scan tras el puente.
heading: Sellar cada petición con la config más reciente
order: 44
tier: 4
functions: fx, streams, scan, filter, map
domain: general
verdict: rxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Una app dispara cuatro peticiones a la API mientras, en segundo
    plano, los despliegues suben la versión de config
    <code>v1 → v2 → v3</code> en desplazamientos fijos. Cada petición
    debe sellarse con la versión de config que estaba vigente
    <em>cuando la petición se disparó</em> — y un cambio de config por sí
    solo no debe emitir nada. Imprime las cuatro peticiones selladas.
    Ambos calendarios están simulados en el código; las dos versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Este es el hermano asimétrico de <code>combineLatest</code>: un
    stream dirige, el otro solo se <em>consulta</em>. El
    <code>withLatestFrom</code> de RxDart <em>es</em> este requisito, con
    nombre — emite por petición, emparejándola con la config más fresca
    vista hasta ahora, y guarda silencio cuando solo cambia la config.
    Qué stream es el primario está codificado en el propio operador.
  </p>
  <p>
    El lado FxDart tiene que construir esa asimetría a mano. Empieza con
    el mismo andamiaje de fusión etiquetada del ejemplo anterior
    (controller, seguimiento del cierre, puente), y luego construye la
    asimetría en el pliegue: un evento de config almacena la versión y
    limpia el hueco de la petición, un evento de petición lo rellena. Un
    <code>filter</code> conserva solo los estados con una petición
    pendiente, y un <code>map</code> formatea el sello. Cada paso es
    tipado y explícito, y ese es el problema: cuatro operadores
    reimplementan lo que <code>withLatestFrom</code> simplemente
    <em>nombra</em>. Veredicto RxDart — la herramienta correcta siempre
    que un stream vivo necesita el último valor de otro.
  </p>
