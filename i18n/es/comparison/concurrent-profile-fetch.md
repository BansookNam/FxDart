---
slug: concurrent-profile-fetch
title: Obtener 10 perfiles, de tres en tres — Dart vs FxDart
description: Preparación síncrona que desemboca directamente en concurrencia acotada — filter y sort, luego toAsync + map + concurrent(3), frente a un pool de workers hecho a mano.
heading: Obtener 10 perfiles, de tres en tres
order: 49
tier: 4
functions: filter, sortBy, toAsync, map, concurrent, join
domain: users
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    De un directorio de doce cuentas, toma las <strong>activas</strong>,
    ordénalas por id y obtén cada perfil de una API (simulada) —sin superar
    nunca <strong>tres peticiones en curso</strong> y con los resultados en
    el orden original. La petición falsa cuenta las peticiones que se
    solapan y ambas versiones imprimen el máximo observado, demostrando que
    el límite se respetó. Los datos están en el código de abajo.
  </p>
  <p>
    Esta es la forma emblemática de toda la sección asíncrona: un pipeline
    síncrono (<code>filter</code> → <code>sortBy</code>) que cruza al mundo
    asíncrono con <code>toAsync</code> y sigue adelante —<code>map</code>
    para la petición, <code>concurrent(3)</code> para acotarla, otro
    <code>map</code> para dar formato y <code>join</code> para terminar. Una
    sola cadena, de la lista al informe.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart nativo resuelve bien la mitad síncrona (<code>where</code> +
    <code>sortedBy</code>), pero en la frontera asíncrona se le acaba el
    vocabulario: acotar la concurrencia conservando el orden significa un
    pool de workers hecho a mano —cursor compartido, huecos de resultado
    predimensionados, un <code>Future.wait</code> sobre los workers—. Ese
    pool es boilerplate de producción de verdad, y parte la tarea en dos
    dialectos: una cadena fluida para la preparación y luego fontanería
    imperativa para las peticiones. En la versión de FxDart la política se
    mantiene declarativa de principio a fin —<code>concurrent(3)</code> es
    el pool de workers entero, y cambiar el límite (o eliminarlo) toca un
    número en lugar de la forma de la función.
  </p>
