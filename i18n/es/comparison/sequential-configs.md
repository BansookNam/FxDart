---
slug: sequential-configs
title: Cargar tres configuraciones remotas en orden — Dart vs FxDart
description: Peticiones asíncronas secuenciales — un simple await dentro de un bucle en Dart frente a toAsync + map en FxDart, a una palabra de la concurrencia acotada.
heading: Cargar tres configuraciones remotas en orden
order: 3
tier: 1
functions: toAsync, map
domain: general
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Carga tres secciones de configuración remota —<code>features</code>,
    <code>limits</code>, <code>theme</code>— desde una API (simulada),
    <strong>de una en una y en orden</strong>, y después imprime cada valor
    cargado. La petición falsa tarda 15 ms fijos; ambas versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Para tres await secuenciales, el bucle <code>for</code> nativo va
    perfectamente —nadie necesita una librería para escribirlo, y si la
    historia acabara aquí esto sería un empate—. La victoria de FxDart está
    en lo que el código llega a ser después:
    <code>toAsync().map(fetchConfig)</code> es un pipeline asíncrono
    perezoso que es secuencial <em>por defecto</em>, y el día que tengas
    treinta configuraciones en lugar de tres, añadir
    <code>.concurrent(8)</code> convierte esa misma cadena en un pool de
    workers acotado —orden preservado, sin tocar nada más—. El bucle nativo
    no tiene semejante mando; hay que reescribirlo. Mira
    <a href="bounded-concurrency.html">Obtener perfiles de dos en dos</a>
    para ese desenlace.
  </p>
