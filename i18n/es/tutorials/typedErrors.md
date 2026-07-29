---
slug: typedErrors
title: Errores tipados — FxDart 101
description: Guía de los errores tipados de FxDart: el constructor either, el ámbito Raise, bind y ensure, la acumulación de errores con NonEmptyList y la validación fusionada con pipelines.
heading: Errores tipados
section: 13
crumb: typed errors
next: either.html
nextLabel: Either
---
  <p class="hero-sub">
    Escribe código en línea recta que falla con un error
    <strong>tipado</strong>. El enfoque de
    <a href="https://arrow-kt.io" rel="noopener">Arrow&nbsp;2.x</a>, la
    librería de Kotlin, portado a Dart.
  </p>

  {{signature}}

  <div class="callout">
    <strong>En profundidad.</strong> Esta página es el resumen; cada tema
    tiene un tutorial detallado con demos ejecutables:
    <a href="either.html"><code>Either</code></a> ·
    <a href="raise.html"><code>either</code> &amp; el ámbito <code>Raise</code></a> ·
    <a href="nullable.html"><code>nullable</code></a> ·
    <a href="nonEmptyList.html"><code>NonEmptyList</code></a> ·
    <a href="accumulate.html">acumulación</a> ·
    <a href="eitherPipelines.html"><code>Either</code> × pipelines</a>
  </div>

  <h2>De Kotlin Arrow a Dart</h2>
  <p>
    En Kotlin Arrow, un bloque <code>either { }</code> convierte una cadena de
    pasos que pueden fallar en código en línea recta: cada <code>.bind()</code>
    o bien desenvuelve un acierto, o bien cortocircuita el bloque entero con el
    fallo:
  </p>
  <pre class="code"><code>// Kotlin Arrow
fun getResult(): Either&lt;Failure, SuccessData&gt; = either {
    val user  = findUser(userId).bind()
    val order = findOrder(user.id).bind()
    val total = calculateTotal(order).bind()
    SuccessData(user, order, total)
}</code></pre>
  <p>FxDart te da la misma forma en Dart:</p>
  <pre class="code"><code>// FxDart
Either&lt;Failure, SuccessData&gt; getResult() => either((r) {
  final user  = r.bind(findUser(userId));
  final order = r.bind(findOrder(user.id));
  final total = r.bind(calculateTotal(order));
  return SuccessData(user, order, total);
});</code></pre>
  <p>
    Los dos sustituyen a la pirámide anidada de <code>flatMap</code> que
    tendrías que escribir si no:
  </p>
  <pre class="code"><code>// A lo que sustituye
Either&lt;Failure, SuccessData&gt; getResult() =>
    findUser(userId).flatMap((user) =>
        findOrder(user.id).flatMap((order) =>
            calculateTotal(order).map((total) =>
                SuccessData(user, order, total))));</code></pre>
  <p>
    Las dos diferencias con Kotlin son realidades de Dart: el ámbito es un
    parámetro explícito (<code>r</code>) porque Dart no tiene receptores en
    las lambdas, y la versión asíncrona tiene su propio constructor
    (<code>eitherAsync</code>) porque Dart no tiene <code>inline</code>. Por
    dentro esto <em>no</em> es encadenado con flatMap: igual que en Arrow,
    <code>r.bind</code> sobre un fallo lanza una señal privada, etiquetada con
    el ámbito, que el constructor captura en la frontera. Por eso los retornos
    tempranos, los bucles y los <code>if</code> funcionan sin más dentro del
    bloque, y por eso los constructores anidados nunca capturan los errores de
    los demás.
  </p>
  <p>
    <a href="either.html">En profundidad: <code>Either</code> →</a>
  </p>

  <h2>El vocabulario del ámbito</h2>
  <p>
    Todo cuelga de la <code>r</code> que te entrega el constructor: escribe
    <code>r.</code> y lo irás descubriendo entero:
  </p>
  <pre class="code"><code>Either&lt;String, int&gt; parsePort(String raw) => either((r) {
  final n = r.ensureNotNull(int.tryParse(raw), () => '"$raw" no es un número');
  r.ensure(n &gt; 0 &amp;&amp; n &lt; 65536, () => '$n está fuera de rango');
  return n;
});

switch (parsePort('8080')) {
  case Right(:final value): print('escuchando en $value');
  case Left(:final value):  print('configuración incorrecta: $value');
}</code></pre>
  <ul>
    <li><code>r.bind(either)</code> / <code>r.bindAll(eithers)</code> —
      desenvuelve o cortocircuita.</li>
    <li><code>r.ensure(cond, () => err)</code> — el <code>require</code> con
      error tipado.</li>
    <li><code>r.ensureNotNull(x, () => err)</code> — devuelve un valor no
      nulo, con promoción de tipo.</li>
    <li><code>r.recover(block, onRaise)</code> — trata un error elevado en un
      ámbito anidado.</li>
    <li><code>r.withError(transform, block)</code> — adapta otro tipo de error
      a este ámbito.</li>
    <li><code>r.raise(err)</code> — cortocircuita directamente; devuelve
      <code>Never</code>.</li>
  </ul>
  <p>
    <code>eitherAsync</code> es el gemelo asíncrono (elevar errores solo dentro
    de la misma cadena de awaits);
    <code>nullable</code>/<code>nullableAsync</code> son los gemelos
    nullable-first que devuelven <code>T?</code> en lugar de un
    <code>Either</code> — FxDart es nullable-first, así que no hay tipo
    <code>Option</code>.
  </p>
  <p>
    <a href="raise.html">En profundidad: <code>either</code> &amp; el ámbito
    <code>Raise</code> →</a> ·
    <a href="nullable.html">En profundidad: <code>nullable</code> →</a>
  </p>

  <h2>Acumula todos los fallos, no solo el primero</h2>
  <p>
    Una validación quiere <em>todos</em> los errores, no el primero. Esta es
    la alternativa de Arrow a tener un tipo <code>Validated</code> aparte:
  </p>
  <pre class="code"><code>final user = either&lt;Nel&lt;String&gt;, User&gt;((r) => r.accumulate((acc) {
  final name = acc.accumulating((r) => validateName(r, input));
  final age  = acc.accumulating((r) => validateAge(r, input));
  return User(name.value, age.value); // todos los errores se informan juntos
}));</code></pre>
  <p>
    <code>r.accumulate</code> ejecuta todas las ramas y concatena todos los
    fallos en una <code>NonEmptyList</code> (<code>Nel</code>): un extension
    type de coste cero que no puede estar vacío. Los atajos de aridad fija
    <code>r.zipOrAccumulate2..5</code> cubren los casos habituales, y
    <code>r.mapOrAccumulate(items, transform)</code> valida una colección
    entera en modo fail-slow. <code>r.bindNel</code> deja que una sola rama
    aporte varios errores a la vez, y
    <code>someEither.toEitherNel()</code> lleva un valor fail-fast a un ámbito
    acumulador.
  </p>
  <p>
    <a href="accumulate.html">En profundidad: acumulación →</a> ·
    <a href="nonEmptyList.html">En profundidad: <code>NonEmptyList</code> →</a>
  </p>

  <h2>Fusionados con los pipelines</h2>
  <p>
    Esta es la parte que no tienen ni Arrow ni ninguna librería de FP de Dart:
    errores tipados fusionados con los pipelines perezosos y conscientes de la
    concurrencia de FxDart.
  </p>
  <pre class="code"><code>// Valida 500 registros, 8 a la vez, y conserva TODOS los fallos — en orden.
final result = await fxStream(records)
    .mapOrAccumulate&lt;String, User&gt;((r, rec) async {
  final parsed = r.ensureNotNull(tryParse(rec), () => 'registro incorrecto: $rec');
  return await enrich(parsed);
}, concurrency: 8);</code></pre>
  <p>
    <code>rights()</code>, <code>lefts()</code>, <code>separated()</code>,
    <code>sequence()</code> (fail-fast: deja de tirar del pipeline en el
    primer <code>Left</code>) y <code>mapOrAccumulate()</code> (fail-slow) son
    terminales ansiosos sobre las cadenas
    <code>fx()</code>/asíncronas. La validación concurrente viaja por el mismo
    canal de retorno <code>concurrent(n)</code> que el resto de FxDart; cada
    elemento se ejecuta en su propio ámbito, así que el fallo de un elemento
    nunca puede filtrarse a otro.
  </p>
  <p>
    <a href="eitherPipelines.html">En profundidad: <code>Either</code> ×
    pipelines →</a>
  </p>

  <h2>Excepciones frente a errores elevados</h2>
  <p>
    La frontera es tajante: los errores <em>elevados</em> son los fallos
    tipados de tu dominio; las excepciones <em>lanzadas</em> son defectos, y
    salen de <code>either</code> sin que nadie las toque. Para capturar un
    throw dentro de un <code>Either</code>, sé explícito:
  </p>
  <pre class="code"><code>final parsed = Either.catching(() => jsonDecode(raw));       // Either&lt;Object, dynamic&gt;
final typed  = Either.catchingWith(ParseFailure.new, () => jsonDecode(raw));</code></pre>
  <p>
    <a href="either.html">En profundidad: <code>Either.catching</code> vive en
    la página de <code>Either</code> →</a>
  </p>

  <div class="callout">
    <strong>Dos reglas.</strong> (1) Nunca devuelvas un pipeline
    <em>perezoso</em> desde un bloque raise: materialízalo con
    <code>toList()</code> o usa los terminales ansiosos de arriba; un raise
    diferido falla ruidosamente con
    <code>RaiseLeakedError</code>. (2) Nunca hagas un <code>catch</code> pelado
    dentro de un bloque raise: usa
    <code>catching</code>/<code>catchingAsync</code>, que siempre dejan pasar
    la señal de cortocircuito (<code>on Exception</code> ya es seguro: la
    señal es un <code>Error</code>).
  </div>

  <p>
    ¿Tienes curiosidad por saber por qué esta página se llama <em>errores
    tipados</em> y no lleva una palabra clave de programación funcional como
    <a href="monad.html"><em>mónada</em></a>?
    <a href="namingOfTypedErrors.html">Las razones del nombre →</a>
  </p>
