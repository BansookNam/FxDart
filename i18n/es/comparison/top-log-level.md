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

  <h2>Adónde se va el tiempo en realidad</h2>
  <p>
    Contar es casi puro trabajo de tabla hash, así que este caso mide en
    realidad cuántas veces toca la tabla cada elemento. Desglosado por coste
    por elemento con N=1.000.000:
  </p>
  <table>
    <thead>
      <tr><th>lo que hace el bucle</th><th>ns por elemento</th></tr>
    </thead>
    <tbody>
      <tr><td>recorrer la lista</td><td>0,3</td></tr>
      <tr><td>+ leer el campo <code>.level</code></td><td>0,7</td></tr>
      <tr><td>+ calcular su hash</td><td>1,7</td></tr>
      <tr><td>+ contar con un <code>switch</code> en cuatro locales</td><td>12,5</td></tr>
      <tr><td>+ <strong>un</strong> sondeo de la tabla</td><td>20,9</td></tr>
      <tr><td>+ <strong>dos</strong> sondeos de la tabla</td><td>29,3</td></tr>
    </tbody>
  </table>
  <p>
    El recorrido y el extractor de clave son gratis: menos de 1 ns entre los
    dos. La tabla lo es todo. Y la línea obvia escrita a mano,
    <code>counts[k] = (counts[k] ?? 0) + 1</code>, sondea la tabla
    <em>dos veces</em>: una para leer y otra para volver a escribir. Ese
    segundo sondeo es cerca del 30% del tiempo de ejecución, y es la razón
    por la que un operador con nombre puede ganarle al bucle que habrías
    escrito. Desde 0.8.4 <code>countBy</code> cuenta en una celda mutable
    alojada en la tabla, así que la lectura devuelve la celda y el incremento
    va por esa referencia: la tabla se escribe una vez por <em>nivel
    distinto</em> en lugar de una vez por entrada.
  </p>

  <h2>Por qué el benchmark se invierte</h2>
  <p>
    Aquí está el mismo caso recorrido en cuatro escalas, con la tercera
    implementación que el párrafo anterior menciona pero no grafica: un bucle
    de conteo escrito a mano, que es lo que escribirías si no estuvieras
    recurriendo a <code>package:collection</code>.
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
      <tr><td>10.000</td><td>351 µs</td><td>291 µs</td><td>199 µs</td>
        <td><strong>1,76× más rápido</strong></td><td><strong>1,46× más rápido</strong></td></tr>
      <tr><td>100.000</td><td>3,6 ms</td><td>2,9 ms</td><td>2,0 ms</td>
        <td><strong>1,83× más rápido</strong></td><td><strong>1,47× más rápido</strong></td></tr>
      <tr><td>400.000</td><td>18,2 ms</td><td>11,6 ms</td><td>7,8 ms</td>
        <td><strong>2,32× más rápido</strong></td><td><strong>1,48× más rápido</strong></td></tr>
      <tr><td>1.000.000</td><td>44,5 ms</td><td>28,8 ms</td><td>19,4 ms</td>
        <td><strong>2,30× más rápido</strong></td><td><strong>1,48× más rápido</strong></td></tr>
    </tbody>
  </table>
  <p>
    Lee primero la última columna, porque es la que no se mueve: frente a
    un bucle escrito a mano FxDart es <strong>~1,47× más rápido en todas las
    escalas</strong>, de diez mil entradas a un millón. Esa constante es el
    único sondeo de la sección anterior: el operador puede permitirse un truco
    demasiado engorroso para escribirlo a mano, y rinde lo mismo con cualquier
    N.
  </p>
  <div class="callout">
    <strong>Esta página decía lo contrario.</strong> Antes de 0.8.4,
    <code>countBy</code> hacía los mismos dos sondeos que el bucle
    <em>más</em> el coste de la cadena, y el número honesto aquí era ~1,4×
    <em>más lento</em> en todas las escalas. Solo se movió la columna de
    FxDart: al volver a medir en la misma máquina, <code>groupListsBy</code>
    y el bucle a mano quedan a menos del 2% de sus cifras anteriores.
  </div>
  <p>
    La columna de <code>groupListsBy</code> abre la brecha todavía más por
    encima de eso, y la columna de memoria es donde eso se ve:
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>bucle a mano</th><th>FxDart</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10.000</td><td>18,8 MB</td><td>14,1 MB</td><td>14,2 MB</td></tr>
      <tr><td>100.000</td><td>33,8 MB</td><td>16,1 MB</td><td>16,2 MB</td></tr>
      <tr><td>400.000</td><td>59,8 MB</td><td>24,7 MB</td><td>24,7 MB</td></tr>
      <tr><td>1.000.000</td><td>88,8 MB</td><td>44,8 MB</td><td>44,8 MB</td></tr>
    </tbody>
  </table>
  <p>
    <code>countBy</code> y el bucle a mano ocupan <strong>la misma
    memoria</strong> — con menos de 0,1 MB de diferencia en cada escala —
    porque ambos guardan cuatro contadores y nada más.
    <code>groupListsBy</code> materializa cada una del millón de entradas
    en <code>List</code>s por nivel solo para tomar sus longitudes, y con
    N=1.000.000 eso son 44 MB de basura que hay que reservar y que el
    recolector debe recorrer.
  </p>
  <p>
    Ese impuesto es además lo que lo vuelve <em>errático</em>. A lo largo
    de 25 muestras con N=1.000.000, <code>groupListsBy</code> osciló entre
    38,8 y 50,1 ms — 11 ms de dispersión — mientras que FxDart se movió
    entre 19,1 y 20,3 ms y el bucle a mano entre 27,9 y 30,4 ms. Sus
    muestras lentas son recolecciones que los otros dos nunca provocan. Así
    que su brecha es en parte tubería y en parte basura; las otras dos
    columnas son solo tubería.
  </p>
  <p>
    La barra de arriba sigue marcando <em>empate</em> con N=10.000 aunque
    FxDart va holgadamente por delante, porque 365 µs frente a 191 µs son
    174 µs: reales, pero por debajo del umbral de 0,6 ms del banco de
    pruebas. Nadie percibe 174 µs, así que la insignia se niega a reclamar
    la victoria.
  </p>
  <p>
    El resumen justo, entonces:
    <strong><code>countBy</code> te da el perfil de memoria de un bucle a
    mano y le gana en tiempo por ~1,47×, con la legibilidad de un operador
    con nombre.</strong> Es uno de esos casos raros en que la versión de la
    biblioteca es sencillamente la mejor opción en todos los ejes, y la razón
    no es una compilación ingeniosa: es que el operador solo hay que
    escribirlo con cuidado una vez.
  </p>
  <div class="callout">
    <strong>Método:</strong> medido en la máquina indicada en la sección
    Benchmark — 5 rondas intercaladas × 5 iteraciones medidas = 25 muestras
    por implementación y escala, compilado AOT, un proceso nuevo por
    muestra, medianas reportadas. Las tres implementaciones devuelven un
    checksum idéntico en todas las escalas.
  </div>
