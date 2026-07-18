---
slug: range
title: range — FxDart 101
description: Tutorial de range en FxDart: una secuencia perezosa de enteros, ascendente o descendente, lista para encadenar.
heading: <code>range</code>
section: 2
crumb: range
prev: consume.html
prevLabel: consume
next: repeat.html
nextLabel: repeat
---
  <p class="hero-sub">Una secuencia perezosa de enteros desde el inicio (incluido) hasta el final (excluido), con el paso que quieras.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>range</code> genera enteros bajo demanda, usando un generador
    <code>sync*</code>: no se reserva nada por adelantado. Llamado con un solo
    argumento, <code>range(4)</code> cuenta <code>0, 1, 2, 3</code> (es decir,
    desde <code>0</code> hasta <code>start</code>, sin incluirlo). Con dos,
    <code>range(1, 4)</code> cuenta <code>1, 2, 3</code>. Un tercer argumento
    fija el paso, incluido un paso <em>negativo</em> para contar hacia atrás:
    por ejemplo, <code>range(4, 1, -1)</code> da <code>4, 3, 2</code>.
  </p>
  <p>
    Como es perezoso, crear <code>range(1000000)</code> resulta prácticamente
    gratis: el millón de enteros solo se produce cuando algo aguas abajo
    (normalmente <code>.take(n)</code>) tira realmente de ellos. Eso convierte
    a <code>range</code> en la fuente de referencia para demostrar la
    evaluación perezosa, y en un sustituto muy práctico siempre que necesites
    "las primeras N cosas" sin construir antes una colección real.
  </p>
  <p>
    A diferencia del <code>range</code> de FxTS, que es un generador finito
    sobre números, este port mantiene el mismo contrato finito: aquí no hay una
    forma ilimitada o infinita (de eso se encarga <code>cycle</code>). Si
    quieres un contador sin fin, combina <code>range</code> con
    <code>cycle</code> y <code>take</code>.
  </p>

  <h2>Demo 1 · Contar hacia arriba, hacia abajo y con pasos</h2>
  {{playground:0}}

  <h2>Demo 2 · La pereza dentro de una cadena</h2>
  <p>
    <code>range(1000000)</code> no produce nada por adelantado: solo los 4
    elementos que pide <code>take(4)</code> pasan realmente por
    <code>map</code>:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: construye los números pares del 2 al 10 incluido usando
    el argumento de paso de <code>range</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="repeat.html"><code>repeat</code></a> — un valor fijo repetido n veces ·
    <a href="cycle.html"><code>cycle</code></a> — repite una secuencia entera para siempre ·
    <a href="take.html"><code>take</code></a> — acota cuánto tiras de un range ·
    <a href="fx.html"><code>fx</code></a> — la cadena en la que range suele envolverse
  </div>
