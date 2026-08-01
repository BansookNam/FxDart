---
slug: accumulate
title: Acumulación de errores — FxDart 101
description: Tutorial de acumulación en FxDart: zipOrAccumulate, accumulate con ramas acumulativas, mapOrAccumulate, bindNel y toEitherNel — recoge todos los fallos, no solo el primero.
heading: acumulación — <code>zipOrAccumulate</code> &amp; compañía
section: 13
crumb: accumulation
prev: nonEmptyList.html
prevLabel: NonEmptyList
next: eitherPipelines.html
nextLabel: Either × pipelines
---
  <p class="hero-sub">
    La validación quiere <em>todos</em> los errores, no solo el primero. Estas
    operaciones ejecutan todas las ramas y concatenan los fallos en un
    <code>NonEmptyList</code> — el sustituto que Arrow 2.x ofrece en lugar de
    un tipo <code>Validated</code> aparte.
  </p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Dentro de <code>either&lt;Nel&lt;E&gt;, _&gt;(...)</code> — cualquier
    ámbito cuyo tipo de error sea un <code>NonEmptyList</code> — el ámbito
    gana el vocabulario de acumulación:
  </p>
  <ul>
    <li><code>r.zipOrAccumulate2..5(branches…, combine)</code> — ejecuta N
      ramas independientes, informa de todos los fallos y combina los
      aciertos.</li>
    <li><code>r.accumulate((acc) { … })</code> — la forma general: ejecuta
      las ramas con <code>acc.accumulating(block)</code> y después lee el
      <code>.value</code> de cada resultado. Si algo falló, leer un valor (o
      llegar al final del bloque) eleva la lista <em>completa</em> de
      errores.</li>
    <li><code>r.mapOrAccumulate(items, transform)</code> — valida una
      colección entera en modo fail-slow.</li>
    <li><code>r.bindNel(eitherNel)</code> — desenvuelve un
      <code>EitherNel</code>, elevando todos sus errores de golpe;
      <code>someEither.toEitherNel()</code> permite introducir un valor
      fail-fast.</li>
  </ul>
  <p>
    El contrato es el de Arrow: todas las ramas se ejecutan (los errores se
    concatenan en el orden de las ramas), una rama que <em>lanza</em> una
    excepción en vez de elevar un error gana sobre la acumulación y, tras el
    primer error, los resultados correctos ya no se conservan: la iteración
    continúa solo para recoger los errores restantes.
  </p>

  <h2>Demo 1 · zipOrAccumulate2</h2>
  {{playground:0}}

  <h2>Demo 2 · accumulate — la forma general</h2>
  {{playground:1}}

  <h2>Demo 3 · mapOrAccumulate, bindNel &amp; toEitherNel</h2>
  {{playground:2}}

  <h2>Demo 4 · dependent — reglas que leen valores hermanos</h2>
  <p>
    Una rama no puede leer el <code>Accumulated.value</code> de una hermana
    sin detonar — la única regla dura de la acumulación. Pero la validación
    real tiene reglas dependientes ("un <em>gasto</em> necesita un
    <em>importe</em> positivo"), y por eso los formularios acababan bajando
    a un guard manual <code>if&nbsp;(!acc.hasErrors)</code>.
    <code>acc.dependent(block)</code> le pone nombre a ese guard: el bloque
    corre solo cuando todas las ramas anteriores tuvieron éxito — así las
    lecturas de <code>.value</code> hermanas dentro son seguras por
    construcción — y se salta por completo en caso contrario. (Sin
    contraparte en Arrow; sus usuarios escriben el mismo guard a mano.)
  </p>
  {{playground:4}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: completa las dos ramas de <code>signup</code> para que la
    segunda llamada informe de <em>ambos</em> fallos.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="nonEmptyList.html"><code>NonEmptyList</code></a> — el portador de los errores ·
    <a href="eitherPipelines.html">Either × pipelines</a> — validación fail-slow sobre cadenas <code>fx()</code>, con concurrencia ·
    <a href="raise.html"><code>either</code> &amp; Raise</a> — el ámbito fail-fast que esto extiende ·
    <a href="typedErrors.html">errores tipados — guía completa</a>
  </div>
