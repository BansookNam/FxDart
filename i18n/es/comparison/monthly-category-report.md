---
slug: monthly-category-report
title: Informe mensual por categorías, ordenado por gasto — Dart vs FxDart
description: Filtra un libro de cuentas a un solo mes, suma cada categoría y ordénalas — bucle más mapa mutable en Dart nativo frente a filter + foldBy + sortBy en FxDart.
heading: Informe mensual por categorías, ordenado por gasto
order: 29
tier: 3
functions: filter, foldBy, map, sortBy, join, foldByOrSkip
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de un libro de cuentas que se desborda de junio a julio de
    2026, construye el informe de gasto de julio: quédate solo con las
    transacciones de julio, suma cada categoría e imprime una línea por
    categoría —<strong>primero el mayor gasto</strong>. Los datos están
    en el código de abajo; ambas versiones deben imprimir las líneas que
    aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart nativo no tiene <code>groupBy</code>, así que el bucle hace la
    agrupación y la suma a la vez dentro de un mapa mutable —compacto,
    pero los cuatro requisitos (solo julio, por categoría, sumado,
    ordenado) quedan enredados en un mismo cuerpo. La cadena de FxDart los
    mantiene como pasos visibles: <code>filter</code> por el mes,
    <code>foldBy</code> por categoría hasta obtener un total,
    <code>map</code> de las entradas a filas, <code>sortBy</code> descendente —y <code>join</code> da
    formato al informe. Añadir un requisito (digamos, un total mínimo) es
    un paso más en la cadena; en el bucle es otra rama dentro de un cuerpo
    que ya estaba cargado.
  </p>

  <h2>Dos formas de escribirlo en FxDart</h2>
  <p>
    El benchmark de abajo lleva una <strong>tercera barra</strong>, que solo
    otra página también tiene. La cadena de arriba es la que conviene
    escribir: <code>filter</code> y <code>foldBy</code> como dos pasos con
    nombre, cada uno respondiendo a una pregunta. Lo que no puede hacer es
    incorporar su propio predicado en línea. <code>filter</code> es una
    etapa perezosa, así que guarda ese predicado en un campo del iterador, y
    el compilador AOT no puede ver a través de un campo: cada transacción
    paga una llamada indirecta real cuyo cuerpo nunca se fusiona con el
    bucle. <code>foldBy</code> no tiene ese problema; es estricto, así que
    sus callbacks son parámetros y se incorporan en línea.
  </p>
  <p>
    <a href="../tutorials/foldByOrSkip.html"><code>foldByOrSkip</code></a>,
    mostrado sobre <code>main</code> en el panel de FxDart, mueve la prueba a
    la clave: una clave <code>null</code> descarta la fila, así que un único
    callback selecciona y agrupa a la vez, y es un parámetro de un cuerpo lo
    bastante pequeño para incorporarse en línea. Con un millón de
    transacciones, esa es la diferencia entre la segunda y la tercera barra;
    la primera es el bucle escrito a mano.
  </p>
  <p>
    Escribe la cadena por defecto: dos preguntas sin relación se leen mejor
    como dos pasos. Recurre a <code>foldByOrSkip</code> cuando el pipeline
    esté en un camino caliente y un perfil indique que ese predicado es el
    coste.
  </p>
