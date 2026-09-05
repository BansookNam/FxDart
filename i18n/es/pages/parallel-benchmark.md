---
slug: parallel-benchmark
title: ¿Merece la pena parallel? — FxDart
description: Un mismo trabajo intensivo en CPU ejecutado de cinco maneras — un bucle simple, isolates a mano, la cadena de fxdart, fxdart parallel y parallel con chunk — medido a tres costes por elemento.
heading: ¿Merece la pena <code>parallel</code>?
---
  <p class="hero-sub">Un trabajo, cinco maneras de ejecutarlo. La respuesta
    depende de un único número, y no es el número al que todo el mundo
    recurre.</p>

  <p>
    Todos los artículos que dicen «usa isolates para el trabajo de CPU» se
    detienen justo antes de la parte que lo decide. Entregar un elemento a
    otro isolate y recuperar el resultado cuesta unos
    <strong>5µs</strong>. Si el trabajo sobre ese elemento cuesta menos que
    eso, no hay número de núcleos que te salve: has contratado un
    mensajero para llevar una carta al otro lado de la habitación.
  </p>
  <p>
    Por eso estos tres casos varían una sola cosa: el coste de un único
    elemento. Todo lo demás — el conjunto de datos, la suma de
    verificación, la función de trabajo — se mantiene fijo, y todos los
    programas llaman a la <em>misma</em> función de nivel superior, así que
    lo único que los diferencia es dónde se ejecuta esa función.
  </p>

  <h2>Cuándo pasar <code>chunk</code> y cuándo no</h2>
  <p>
    Imagina diez habitaciones al fondo del pasillo, una persona en cada
    una. Para dar un trabajo caminas, entregas una hoja y vuelves con la
    respuesta. Ese camino son unos <strong>5µs</strong> — un instante —
    cada vez, aunque la hoja esté casi en blanco. El número
    <code>10</code> es cuántas habitaciones contrataste. En esta página
    es 10 porque la máquina que midió los gráficos tiene 10 núcleos.
  </p>
  <p>
    <strong>Deja <code>chunk</code> fuera</strong> cuando el trabajo de
    una hoja es pesado. Abajo hay 20.000 contraseñas y 10 trabajadores.
    Rehashear una contraseña tarda unos 250µs — cincuenta caminos de
    trabajo. Entonces el camino es ruido. Envía una contraseña por
    viaje. Son 20.000 caminos, y está bien:
  </p>
  <pre><code>// 20,000 passwords, 10 workers. No chunk.
await fx(creds).parallel(10, rehash).toList();
// 20,000 trips. Each trip ~5µs, each job ~250µs.</code></pre>
  <p>
    <strong>Pasa <code>chunk</code></strong> cuando el trabajo de una
    hoja es más ligero que el camino. Abajo hay 1.500.000 líneas de log
    y 10 trabajadores. La huella de una línea tarda unos 3,5µs — menos
    que un camino. Una línea por viaje son 1.500.000 caminos, más lento
    que hacerlo en tu propio escritorio. En su lugar mete 37.500 líneas
    en cada sobre
    (<code>1,500,000 ~/ (10 * 4) = 37,500</code>). ¿Por qué
    <code>10 * 4</code>? Diez habitaciones, cuatro sobres cada una, así
    que 40 viajes en lugar de 1.500.000 — y si un sobre va más lento,
    las otras habitaciones aún tienen tres para repartir:
  </p>
  <pre><code>// 1,500,000 log lines, 10 workers, 37,500 lines per envelope.
await fx(lines).parallel(10, fingerprint, chunk: 37500).toList();
// 40 trips. 1,500,000 / (10 * 4) = 37,500.</code></pre>

  <h2>Las cinco maneras</h2>
  <ol>
    <li><strong>Nativo, un isolate</strong> — un bucle <code>for</code>
      simple. La referencia contra la que se mide todo lo demás, porque es
      el aspecto que tenía el código antes de que nadie buscara una
      biblioteca.</li>
    <li><strong>Nativo + <code>dart:isolate</code></strong> — trocea la
      lista, un <code>Isolate.run</code> por trozo, <code>Future.wait</code>
      y concatena. Esto es lo que escribes a mano, y es el listón que
      <code>parallel</code> tiene que superar: no basta con ganarle al
      bucle.</li>
    <li><strong>Cadena de fxdart, un isolate</strong> —
      <code>fx(xs).map(work).toList()</code>. No comparte nada con los
      isolates; está aquí para ponerle precio a la cadena en sí, de modo que
      a la fila de abajo no se le regale ni se le cargue ese coste.</li>
    <li><strong>fxdart <code>.parallel()</code></strong> — la misma cadena
      con un operador cambiado, en su forma por defecto: cada elemento cruza
      solo hasta un trabajador. Esto es lo que escribes primero.</li>
    <li><strong>fxdart <code>.parallel(chunk:)</code></strong> — el mismo
      operador con <code>k</code> elementos en cada mensaje, de modo que el
      viaje se paga una vez por lote en lugar de una vez por elemento. Las
      dos últimas filas están juntas a propósito: el hueco entre ellas
      <em>es</em> el viaje de ida y vuelta, dibujado a escala.</li>
  </ol>

  <h2>Cómo leer los números</h2>
  <p>
    Cada caso está dimensionado para que el bucle simple tarde unos
    <strong>cinco segundos</strong>. Es deliberado: por debajo de un
    segundo, arrancar los isolates (~1ms cada uno) y copiar los datos pesan
    tanto sobre el total que la medición habla sobre todo del instrumento.
    Un trabajo que merece paralelizarse es un trabajo que tarda un rato.
  </p>
  <p>
    Los dos bloques pequeños ejecutan el mismo programa con
    N&nbsp;=&nbsp;10.000 y N&nbsp;=&nbsp;100. No son relleno: son la otra
    mitad de la respuesta. Los isolates tienen un precio fijo — cerca de un
    milisegundo por arrancar cada uno, más copiar los datos de ida y los
    resultados de vuelta. Cuanto más pequeño es el trabajo, menos queda por
    ganar, y dónde está ese cruce no se adivina solo con el número de
    elementos. Fíjate en que <code>password-rehash</code> sigue ganando con
    N&nbsp;=&nbsp;100 mientras que <code>log-fingerprint</code> ya ha
    perdido con N&nbsp;=&nbsp;10.000: lo que decide es el trabajo total, no
    cuántas cosas hay.
  </p>

  <div class="callout">
    <strong>Qué mirar.</strong> En
    <code>password-rehash</code> cada elemento cuesta ~250µs — cincuenta
    veces el viaje — y <code>parallel</code> gana sin ajustar nada. En
    <code>log-fingerprint</code> cada elemento cuesta ~3,5µs, <em>menos</em>
    que el viaje, y <code>parallel</code> por defecto es <em>más lento que
    el bucle simple</em>. No es un defecto: es pedirle al operador que pague
    un precio por elemento por un trabajo que se mide por elemento.
    <code>chunk:</code> es la solución, y las dos últimas filas son cuánto
    vale.
  </div>

  <h2>Por qué más trabajadores no arreglan la fila lenta</h2>
  <p>
    Si a <code>log-fingerprint</code> simplemente le faltara paralelismo, un
    grupo más grande ayudaría. No lo hace. El mismo programa con
    N&nbsp;=&nbsp;100.000, variando solo el número de trabajadores:
  </p>
  <pre><code>workers   .parallel()        .parallel(chunk:)
      1     768.8 ms             381.0 ms
      2     831.9 ms             191.1 ms
      5     899.1 ms              86.5 ms
     10     873.5 ms              71.0 ms</code></pre>
  <p>
    Esta tabla es una medición aparte (<code>BENCH_N=100000</code>,
    <code>BENCH_WORKERS</code> 1–10). No está en
    <code>results-parallel.json</code>, así que regenerar los gráficos
    de la página no refresca estas cuatro filas.
  </p>
  <p>
    La forma por defecto no mejora en absoluto — se va poniendo algo
    <em>peor</em>, y su coste se queda en torno a 8µs por elemento sea cual
    sea el tamaño del grupo. La forma con lotes escala 5,4× en ese mismo
    rango.
  </p>
  <p>
    Ese es el diagnóstico. Con <code>chunk: 1</code>, cada elemento cuesta
    dos copias de mensaje, un evento de puerto y un completer <strong>en el
    isolate principal</strong>, que es un único hilo y lo único del sistema
    que no se puede paralelizar. Unos 8µs de coordinación (el viaje más
    ese completer y ese evento) para repartir 3,5µs de trabajo. El cuello
    de botella no son los trabajadores: están parados, esperando a que les
    dé trabajo un isolate principal que se pasa el tiempo echando cartas al
    buzón. Añadir trabajadores solo añade contención por él.
  </p>
  <p>
    Un lote no abarata la coordinación: hace que haya menos. La fila con
    lote usa <code>n ~/ (workers * 4)</code>, así que diez trabajadores
    siempre envían 40 mensajes. En este barrido eso es
    <code>chunk: 2500</code> en lugar de 100.000 viajes; en el titular
    (N = 1.500.000) es <code>chunk: 37500</code> en lugar de 1,5 millones
    de viajes. El isolate principal deja de ser el cuello de botella y el
    trabajo por fin llega a donde tenía que ir.
  </p>

  <p>
    Fuentes: <code>benchmark/cases-parallel/</code>. Se regenera con
    <code>dart run benchmark/run_parallel_benchmarks.dart</code>. El
    ejecutor rechaza un caso cuyas variantes no produzcan todas una suma de
    verificación idéntica, así que las filas son siempre maneras distintas
    de calcular una misma respuesta.
  </p>
