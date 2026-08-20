---
slug: theory
title: Teoría de la programación funcional — FxDart 101
description: Un libro de texto sobre las ideas detrás de FxDart — mónadas, functores, leyes, evaluación perezosa y errores tipados — escrito para desarrolladoras y desarrolladores de Dart en activo, con cada listado ejecutable en el navegador.
heading: Teoría de la programación funcional
---
## Cómo leer este libro

Este es el compañero teórico de FxDart 101. Los tutoriales responden a *cómo
llamo a esta función*; este libro responde a *por qué la función tiene esa
forma*, y *qué garantiza esa forma*.

Está escrito para quien programa en Dart a diario. Eso significa tres cosas.

**Sin más requisitos que Dart.** Nada de Haskell, nada de teoría de
categorías, ninguna matemática más allá de la idea de que una función lleva
entradas a salidas. Cuando un concepto tiene definición formal, la tendrás
—pero después de haber usado ya aquello que nombra.

**Todos los listados se ejecutan.** El código marcado con un botón **▶ Run**
compila con el compilador real de Dart y se ejecuta en esta página. La
primera ejecución descarga el runtime del compilador y tarda unos segundos;
a partir de ahí es instantánea. Las afirmaciones sobre *qué imprime un
programa* están para comprobarse, no para creerse.

**Honestidad antes que propaganda.** Algunas de estas ideas se pagan solas en
la primera hora. Otras son elegantes y, en Dart, no compensan la fricción
—Dart no puede expresar varias de ellas en absoluto, y donde ocurre eso este
libro lo dice y muestra qué hace FxDart en su lugar.

### Pasar páginas

Usa las flechas, las teclas ← y →, o **Contents** para saltar a un capítulo.
Cada capítulo termina con ejercicios; las soluciones están en el pliego
siguiente, así que puedes pensar antes de pasar la página.

> **Notación.** `A`, `B` son tipos corrientes (`int`, `User`). `M<A>` es un
> valor de tipo `A` situado dentro de alguna estructura `M` — `List<A>`,
> `Future<A>`, `Either<E, A>`. Una función escrita `A → M<B>` toma un valor
> plano y devuelve uno que está dentro de la estructura. Esa única forma es
> de lo que trata la mayor parte de la Parte I.
