---
slug: reading
chapter: 0
part: 6
title: Apéndice C · Lecturas adicionales
description: Adónde ir después, con una nota honesta sobre la dificultad de cada fuente y para qué sirve en realidad.
---
# Apéndice C · Lecturas adicionales

Ordenadas por lo pronto que resultan útiles, con una nota clara sobre su
dificultad. Nada de esto es obligatorio; cada capítulo de este libro se
sostiene por sí solo.

## Dentro de este proyecto

| Fuente | Buena para | Dificultad |
|---|---|---|
| **Tutoriales de FxDart 101** | la superficie de la API, una función cada vez, con demos ejecutables | fácil |
| **Dart vs FxDart** (52 ejemplos) | si una tubería es la herramienta adecuada para una tarea dada, con veredictos | fácil |
| **RxDart vs FxDart** | la decisión pull/push del capítulo 12, aplicada a 50 problemas reales | fácil |
| **`WHY_CURRIED.md`** | el razonamiento detrás del capítulo 4 — qué le debe un port a su fuente | moderada |
| **`ARROW_MIGRATION_BLOCKER.md`** | el muro de los HKT del capítulo 10, documentado tal como se topó con él | moderada |
| **`benchmark/AUTHORING.md`** | cómo se producen las cifras del capítulo 14, y cómo añadir un caso | moderada |

## La documentación de los antecesores

| Fuente | Buena para | Dificultad |
|---|---|---|
| **Arrow (Kotlin) — guía de errores tipados** | la especificación de la parte IV, en la práctica; el ámbito `Raise`, la acumulación y la razón de ser del diseño | moderada |
| **Documentación de FxTS** | el catálogo de operadores y `concurrent(n)`; los nombres se corresponden casi exactamente con FxDart | fácil |
| **Cats (Scala) — documentación de typeclasses** | la torre enunciada de forma genérica: functor → applicative → mónada → recorrido | difícil sin Scala |
| **`Data.Functor` / `Control.Monad` de Haskell** | las leyes en su forma original, con concisión | difícil |

## Artículos y charlas que merecen el tiempo

- **Philip Wadler, *Monads for functional programming* (1992).** El artículo
  que convirtió la semántica de Moggi en una técnica de programación. Sigue
  siendo la motivación más clara de por qué merece la pena tratar los efectos
  como valores. *Moderado; sáltate la sintaxis de Haskell si no te resulta
  familiar y lee la prosa.*
- **Conor McBride & Ross Paterson, *Applicative programming with effects*
  (2008).** Donde se nombró el applicative. El capítulo 6 es un resumen de
  sus tres primeras páginas. *Moderado.*
- **Scott Wlaschin, *Railway Oriented Programming* (charla, 2014).** La
  imagen que usa el capítulo 16, bien presentada. *Fácil — la mejor primera
  charla sobre errores tipados.*
- **Erik Meijer, *Subject/Observer is Dual to Iterator* (2010).** La dualidad
  del capítulo 12, de boca de quien construyó Rx sobre ella. *Moderado.*
- **Eugenio Moggi, *Notions of computation and monads* (1991).** El origen.
  *Difícil — léelo después de Wadler, o no lo leas.*

## Libros

- **Scott Wlaschin, *Domain Modeling Made Functional*.** Los capítulos 3, 16
  y 18 de este libro, ampliados en un método práctico completo, en F#. La
  mejor recomendación única para quien trabaja en el día a día. *Fácil a
  moderado.*
- **Bartosz Milewski, *Category Theory for Programmers*.** El capítulo 20 con
  mucho más detalle, gratis en internet, paciente con quien empieza.
  *Moderado; los ejercicios son donde está el aprendizaje.*
- **Runar Bjarnason & Paul Chiusano, *Functional Programming in Scala*.**
  Construye toda la torre desde cero como ejercicios. Excelente, y una
  inversión de tiempo seria. *Difícil.*
- **Graham Hutton, *Programming in Haskell*.** Si decides aprender el
  lenguaje de origen, esta es la ruta completa más suave. *Moderado.*

## Qué leer para una pregunta concreta

| Quieres saber | Ve a |
|---|---|
| «¿Qué función de FxDart hace X?» | los tutoriales 101 |
| «¿Debería usar aquí una tubería?» | Dart vs FxDart, y el capítulo 22 |
| «¿Cómo modelo este fallo?» | el capítulo 18, y luego la guía de errores tipados de Arrow |
| «¿Por qué no hay un `traverse` genérico?» | el capítulo 10, y luego `ARROW_MIGRATION_BLOCKER.md` |
| «¿Es legal mi tipo?» | el capítulo 19 y el apéndice B, y luego escribe el test de propiedades |
| «¿Qué es realmente una mónada?» | el capítulo 1, luego Wadler, luego el capítulo 20 |

## Una nota final sobre cómo leer teoría

El orden que funciona es: **úsalo, nómbralo, y luego formalízalo.** Cada
capítulo de este libro se escribió así, y las fuentes de arriba se abordan
mejor de la misma manera — encuentra la construcción que ya has estado
usando, lee la sección que la nombra, y detente ahí hasta la próxima vez que
te la encuentres.

Leer un libro de teoría de principio a fin sin código delante es el enfoque
que produce la fama, y no funciona.
