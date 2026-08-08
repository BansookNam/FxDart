---
slug: top-log-level
title: Nivel de log más frecuente — Dart vs FxDart
description: Contar entradas de log por nivel y quedarse con el mayor — groupListsBy + reduce en Dart nativo frente a countBy + maxBy en FxDart.
heading: Nivel de log más frecuente
order: 2
tier: 1
functions: countBy, maxBy
domain: logs
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dado un fragmento de los logs de una aplicación, cuenta cuántas entradas
    tiene cada <strong>nivel</strong> (INFO / WARN / ERROR) e imprime el más
    frecuente junto con su recuento. Los datos están en el código de abajo;
    ambas versiones deben imprimir la línea que aparece bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart nativo no tiene <code>countBy</code>: lo más parecido es el
    <code>groupListsBy</code> de <code>package:collection</code>, que
    construye una lista con <em>todas las entradas</em> de cada nivel solo
    para que puedas quedarte con sus longitudes — o un bucle con
    <code>Map.update</code> escrito a mano. Elegir después al ganador
    requiere un <code>reduce</code> con una comparación explícita. FxDart
    pone nombre a ambos pasos: <code>countBy</code> va directo a los
    recuentos (es terminal — devuelve un <code>Map</code> corriente), y
    <code>fx(counts.entries).maxBy(...)</code> vuelve a entrar en la cadena
    para elegir la entrada más grande. Dos ideas con nombre en lugar de dos
    construidas a mano.
  </p>

  <h2>Por qué el benchmark se invierte</h2>
  <p>
    Las barras de arriba se prestan a confusión: FxDart <em>pierde</em> con
    N=10.000 y <em>gana</em> con N=1.000.000. Ambas cosas son ciertas, y
    ninguna es lo que parece. Aquí está el mismo caso recorrido en cuatro
    escalas, con la tercera implementación que el párrafo anterior menciona
    pero no grafica: un bucle de conteo escrito a mano, que es lo que
    escribirías si no estuvieras recurriendo a
    <code>package:collection</code>.
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>bucle a mano</th>
        <th>FxDart</th><th>frente a <code>groupListsBy</code></th>
        <th>frente al bucle</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10.000</td><td>345 µs</td><td>288 µs</td><td>415 µs</td>
        <td>1,20× más lento</td><td>1,44× más lento</td></tr>
      <tr><td>100.000</td><td>3,48 ms</td><td>2,87 ms</td><td>4,16 ms</td>
        <td>1,20× más lento</td><td>1,45× más lento</td></tr>
      <tr><td>400.000</td><td>18,7 ms</td><td>11,6 ms</td><td>16,4 ms</td>
        <td><strong>1,14× más rápido</strong></td><td>1,41× más lento</td></tr>
      <tr><td>1.000.000</td><td>45,2 ms</td><td>28,5 ms</td><td>40,8 ms</td>
        <td><strong>1,11× más rápido</strong></td><td>1,43× más lento</td></tr>
    </tbody>
  </table>
  <p>
    Lee primero la última columna, porque es la que no se mueve: frente a
    un bucle escrito a mano FxDart es <strong>~1,4× más lento en todas las
    escalas</strong>, de diez mil entradas a un millón. Ese es el coste
    honesto de la cadena — unos 7 ns por elemento para el envoltorio
    <code>fx()</code> y el despacho de closures a través de
    <code>countBy</code>. Nunca mejora, y ningún N hace que la tubería de
    FxDart sea más rápida que un bucle.
  </p>
  <p>
    Así que la inversión de la columna central no es FxDart acelerando. Es
    <code>groupListsBy</code> <em>frenándose</em>, y la columna de memoria
    es donde eso se ve:
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>bucle a mano</th><th>FxDart</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10.000</td><td>19,7 MB</td><td>14,7 MB</td><td>14,8 MB</td></tr>
      <tr><td>100.000</td><td>35,3 MB</td><td>16,8 MB</td><td>16,9 MB</td></tr>
      <tr><td>400.000</td><td>62,6 MB</td><td>25,8 MB</td><td>25,9 MB</td></tr>
      <tr><td>1.000.000</td><td>83,3 MB</td><td>46,9 MB</td><td>47,0 MB</td></tr>
    </tbody>
  </table>
  <p>
    <code>countBy</code> y el bucle a mano ocupan <strong>la misma
    memoria</strong> — con menos de 0,1 MB de diferencia en cada escala —
    porque ambos guardan cuatro contadores enteros y nada más.
    <code>groupListsBy</code> materializa cada una del millón de entradas
    en <code>List</code>s por nivel solo para tomar sus longitudes, y con
    N=1.000.000 eso son 36 MB de basura que hay que reservar y que el
    recolector debe recorrer.
  </p>
  <p>
    Ese impuesto es además lo que lo vuelve <em>errático</em>. A lo largo
    de 25 muestras con N=1.000.000, <code>groupListsBy</code> osciló entre
    42,1 y 49,5 ms, mientras que FxDart se movió entre 40,3 y 42,2 ms. Su
    mejor tiempo prácticamente empata con el mejor de FxDart; pierde en la
    mediana porque a veces se detiene para una recolección que FxDart nunca
    provoca. La victoria por encima de ~200.000 es la ausencia de basura,
    no una tubería más rápida.
  </p>
  <p>
    Y la derrota con N=10.000 es igual de honesta: 415 µs frente a 345 µs
    son 70 µs — reales, pero por debajo del umbral de 0,6 ms del banco de
    pruebas, que es por lo que la barra de arriba sigue marcando
    <em>empate</em>. Nadie percibe 70 µs.
  </p>
  <p>
    El resumen justo, entonces:
    <strong><code>countBy</code> te da el perfil de memoria de un bucle a
    mano con la legibilidad de un operador con nombre, a alrededor de 1,4×
    el tiempo de ese bucle.</strong> Si ese intercambio compensa es un
    juicio sobre tu código, no un número — pero le gana a la línea
    idiomática de <code>package:collection</code> en ambos ejes en cuanto
    los datos crecen, y nunca te cuesta esos 36 MB.
  </p>
  <div class="callout">
    <strong>Método:</strong> medido en la máquina indicada en la sección
    Benchmark — 5 rondas intercaladas × 5 iteraciones medidas = 25 muestras
    por implementación y escala, compilado AOT, un proceso nuevo por
    muestra, medianas reportadas. Las tres implementaciones devuelven un
    checksum idéntico en todas las escalas.
  </div>
