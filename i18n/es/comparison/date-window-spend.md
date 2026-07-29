---
slug: date-window-spend
title: Gasto dentro de una ventana de fechas — Dart vs FxDart
description: Suma un tramo de un libro ordenado por fecha — skipWhile/takeWhile/fold en Dart nativo frente a dropWhile + takeWhile + sumBy en FxDart. Dart nativo aguanta bien.
heading: Gasto dentro de una ventana de fechas
order: 13
tier: 2
functions: dropWhile, takeWhile, sumBy
alsoLink: fx
domain: transactions
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Una exportación del libro de cuentas ya viene <strong>ordenada por
    fecha</strong>. Suma el gasto entre el <strong>2026-07-08 y el
    2026-07-21</strong>, ambos incluidos, sin recorrer la lista entera:
    salta las entradas anteriores a la ventana, toma entradas mientras
    sigas dentro de ella y suma lo que quede. Los datos están en el código
    de abajo; las dos versiones deben imprimir la línea que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas. Dart trae <code>skipWhile</code> y <code>takeWhile</code> en
    todo <code>Iterable</code>, y ambos son perezosos: la versión en Dart
    nativo aprovecha el orden exactamente igual que la de FxDart, y se lee
    igual de bien. La única diferencia real está en el último paso:
    <code>sumBy</code> nombra la intención, mientras que <code>fold</code>
    deletrea el valor inicial y la combinación. Eso es ganar por una
    palabra, no por estructura —llamémoslo empate. Si tu código ya encadena
    con <code>fx</code>, úsalo aquí por coherencia; si no, Dart nativo va
    bien.
  </p>
