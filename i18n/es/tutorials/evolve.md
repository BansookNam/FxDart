---
slug: evolve
title: evolve — FxDart 101
description: Tutorial de evolve en FxDart: transforma valores concretos de un Map según su clave, dejando el resto intacto.
heading: <code>evolve</code>
section: 9
crumb: evolve
prev: props.html
prevLabel: props
next: compactObject.html
nextLabel: compactObject
---
  <p class="hero-sub">Pasa los valores seleccionados por funciones de transformación asociadas a cada clave, dejando el resto del <code>Map</code> tal cual.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>evolve</code> recibe un map de "receta" —clave a función de
    transformación— y un map de datos, y produce un map nuevo en el que cada
    clave que aparece en la receta pasa su valor por la función
    correspondiente; el resto de las claves se copian sin cambios.
  </p>
  <p>
    Fíjate en que la firma es deliberadamente laxa: ambos maps están tipados
    con valores <code>Object?</code>, reflejando el original de FxTS con
    tipado dinámico. Eso significa que tus funciones de transformación
    reciben <code>Object?</code> y deben hacer un cast
    (<code>v as String</code>, <code>v as int</code>, …) antes de hacer nada
    específico de un tipo: un pequeño peaje a cambio de la flexibilidad de
    aplicar transformaciones distintas a tipos de valor distintos dentro de un
    mismo map. Si conoces de antemano la forma de tus datos y no necesitas esa
    heterogeneidad por clave, un simple spread
    <code>{...map, 'key': f(map['key'])}</code> suele ser Dart más
    idiomático; recurre a <code>evolve</code> cuando la propia receta sea
    datos (por ejemplo, construida una vez y reutilizada en muchos maps).
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Parsear campos de texto en crudo</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>evolve</code> para duplicar el campo <code>'price'</code> y dejar <code>'title'</code> intacto.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="prop.html"><code>prop</code></a> — leer un único valor ·
    <a href="omitBy.html"><code>omitBy</code></a> — descartar entradas en lugar de transformarlas ·
    <a href="compactObject.html"><code>compactObject</code></a> — una pasada de limpieza especializada ·
    <a href="resolveProps.html"><code>resolveProps</code></a> — el primo asíncrono, que espera en lugar de transformar
  </div>
