---
slug: lineage
chapter: 21
part: 5
title: Linaje
description: De Haskell a Scala a Arrow de Kotlin a FxTS a FxDart — cinco traducciones de las mismas ideas, y qué tuvo que ceder cada una para encajar en su lenguaje anfitrión.
---
# Linaje

> **En este capítulo**
> - dónde se inventó cada idea de este libro, y qué problema resolvía ahí
> - las cuatro traducciones, y lo específico que perdió cada una
> - por qué la API de FxDart se ve como se ve — los nombres de FxTS, los errores de Arrow
> - qué tomar de cada ancestro cuando lees su documentación

## Cinco lenguajes, un conjunto de ideas

| | Introdujo / popularizó | Perdido en la traducción |
|---|---|---|
| **Haskell** (1990) | typeclasses, mónadas como interfaz, `do` | nada — es la fuente; el costo es el propio lenguaje |
| **Scala** (2004) | mónadas en un lenguaje OO, `for`-comprehensions, Cats | complejidad de resolución de implícitos; dos sintaxis para todo |
| **Kotlin + Arrow** (2017) | errores tipados sin HKTs, `Raise`, context receivers | abstracción genérica sobre efectos — eliminada en Arrow 2 |
| **FxTS** (2021) | tuberías perezosas, `concurrent(n)`, en TypeScript | leyes como contrato declarado; los tipos de TS se borran en tiempo de ejecución |
| **FxDart** (2025) | el modelo de FxTS + los errores de Arrow, en Dart | `pipe` curried, y toda abstracción HKT |

Lee la columna derecha como una sola frase: **cada traducción conservó la
forma y descartó lo que su lenguaje anfitrión no podía cargar.**

![Qué conservó cada traducción](diagrams/t21-1-lineage.svg)

*Figura 21-1. Las ideas viajan; los mecanismos no. Cada flecha es un port
que preservó el vocabulario y reimplementó la maquinaria con lo que tenía
el nuevo lenguaje.*

## Haskell: de dónde vino la interfaz

Las mónadas se introdujeron en Haskell para resolver un problema
específico — cómo un lenguaje *puro* puede hacer IO — y la respuesta fue
convertir los efectos en valores con una interfaz común. Esa interfaz es un
typeclass, que es por qué cada capítulo de la Parte II tiene la forma de
uno: un constructor de tipo, un par de operaciones, y leyes que las
instancias deben satisfacer.

Lo que Haskell aportó y sobrevive en todas partes: **las leyes son el
contrato.** Una instancia de `Monad` que rompe la asociatividad es un bug,
no una variante. Cada librería de este linaje hereda ese estándar aunque no
pueda imponerlo.

Lo que no se traduce: la pereza por defecto, la pureza impuesta por el
compilador, y la resolución de typeclasses. Leer Haskell por las ideas vale
la pena; copiar sus firmas a Dart no.

## Scala: las mónadas se encuentran con los objetos

Scala demostró que el vocabulario funciona en un lenguaje con subtipado y
métodos — `flatMap` como método en vez de función libre, `for` como
desugaring, y (en Cats) toda la torre de typeclasses recreada con
implícitos y tipos de orden superior.

También demostró el modo de fallo que hizo cautos a los diseñadores
posteriores: `EitherT[Future, E, A]` y compañía. Los monad transformers son
la respuesta general a "las mónadas no componen", y en la práctica
producen código con un lift en cada nivel y mensajes de error imposibles
para un recién llegado. La caja de profundidad del capítulo 7 registra por
qué tanto Arrow como FxDart rechazaron esta ruta.

## Arrow de Kotlin: errores tipados sin la torre

Arrow 1.x intentó ser Cats para Kotlin, incluyendo la codificación `Kind`
que demostró el capítulo 10. Arrow 2.x eliminó casi todo eso y lo
reconstruyó alrededor de una idea: **un scope con una salida no local.**

```
either { val x = parse(raw).bind(); ... }      // Kotlin, Arrow 2
either((r) { final x = r.bind(parse(raw)); ... })  // Dart, FxDart
```

Ese es el ancestro directo del capítulo 15, y la razón por la que la API de
errores tipados de FxDart usa el vocabulario de Arrow — `Raise`, `bind`,
`ensure`, `accumulate`, `NonEmptyList`, `zipOrAccumulate` — en vez de
inventar nombres nuevos. Cuando la documentación de Arrow explica una
sutileza sobre la acumulación, también se aplica aquí.

Kotlin tiene algo que Dart no: context receivers, que dejan que `bind()`
sea una extensión disponible implícitamente dentro del scope. Dart necesita
el prefijo explícito `r.`. Esa es una pérdida ergonómica real y la razón
por la que los scopes de FxDart son "scope-first por diseño": escribes `r.`
y el editor lista el vocabulario.

## FxTS: la mitad de la tubería

Todo en las Partes I y III viene del otro padre. FxTS aportó:

- tuberías perezosas construidas con pequeños operadores, síncronas y
  asíncronas bajo un mismo vocabulario;
- `concurrent(n)` y su canal de retorno — el mecanismo del capítulo 13,
  inventado ahí;
- los nombres que FxDart sigue casi al pie de la letra, así que un usuario
  de FxTS puede leer código de FxDart.

Lo que no se pudo portar es el tema del capítulo 4: el `pipe` curried de
FxTS necesita genéricos variádicos, que TypeScript simula con overloads y
Dart no puede simular en absoluto. La cadena tipada de FxDart es el
reemplazo, y `WHY_CURRIED.md` es el registro escrito de esa decisión —
vale la pena leerlo como ejemplo de documentar las desviaciones de un port
en vez de fingir que no existen.

## FxDart: qué es, exactamente

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parse(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad: $s') : Either.right(n);
}

void main() async {
  // FxTS ancestry: lazy chain, bounded concurrency.
  final ports = await fx(['8080', '9000', '7000'])
      .toAsync()
      .mapConcurrent(2, (s) async => s)
      .toList();

  // Arrow ancestry: typed failures, scope, accumulation.
  final parsed = fx(ports).map(parse).flattenOrAccumulate();

  print(parsed);
  print(fx(['1', 'x']).map(parse).flattenOrAccumulate());
}
```

Dos linajes, una librería, y la costura entre ellos es deliberada: la mitad
de la tubería nunca menciona `Either`, y la mitad de errores nunca menciona
la pereza. Se encuentran solo en los recorridos del capítulo 9.

> 🎓 **Ideas más viejas que todas ellas.** Las mónadas entraron en la
> computación a través del trabajo de Eugenio Moggi de 1989 sobre la
> semántica categórica de los programas, y los papers de Philip Wadler las
> convirtieron en una técnica de programación. `NonEmptyList`, la
> validación aplicativa y la imagen del "ferrocarril" vienen de la práctica
> de ML y Haskell de ese mismo período. Las continuaciones delimitadas — el
> mecanismo del capítulo 15 — son todavía más viejas, del Scheme de los años
> 80. Casi nada de este libro se inventó en la última década; lo que cambió
> es que los lenguajes convencionales crecieron suficiente sistema de tipos
> para hospedar las ideas, que es por qué el mismo conjunto llegó a Kotlin,
> TypeScript, Swift y Dart en unos pocos años entre sí.

## Leyendo a los ancestros

- **Haskell** — léelo por las *leyes* y por cómo se ve una interfaz cuando
  el compilador la comprueba. Ignora los debates de sintaxis.
- **Scala/Cats** — léelo por la *torre*: aplicativo, traverse, monoide, y
  sus relaciones enunciadas genéricamente. Ignora la pila de transformers a
  menos que la disfrutes.
- **Arrow (Kotlin)** — lee directamente los docs de errores tipados y
  acumulación; son lo más cercano que tiene FxDart a una especificación
  para la Parte IV.
- **FxTS (TypeScript)** — léelo por el catálogo de operadores y el modelo
  de concurrencia; los nombres de FxDart coinciden, y los ejemplos suelen
  traducirse línea por línea.

## Cuándo se gana el sueldo

Cuando estás atascado. Casi toda pregunta que puedas hacer sobre este
vocabulario ha sido respondida largamente en una de las cuatro comunidades
ancestrales, y saber cuál buscar es la mayor parte del trabajo.

También se gana el sueldo como inoculación: ver que cada lenguaje pagó un
precio distinto por las mismas ideas deja claro que las ideas no son
propiedad de ninguna sintaxis — y que un port de Dart que rechaza una
característica de Haskell suele ser una decisión de diseño, no una
carencia.

## Ejercicios

1. Arrow 2 eliminó su codificación `Kind` y su tipo `Validated`. ¿Qué costó
   cada eliminación, y qué compró?
2. El `pipe` de FxTS toma un valor y una lista de operadores curried; la
   cadena de FxDart es métodos. Nombra algo que FxTS puede expresar y
   FxDart no, y algo que FxDart obtiene y FxTS no.
3. Scala resuelve `Future` + `Either` con `EitherT`; FxDart lo resuelve con
   `eitherAsync`. ¿Cuál de los dos generaliza a un tercer efecto, y qué
   hace el otro en su lugar?
4. ¿Qué capítulos de este libro habría que reescribir si Dart ganara tipos
   de orden superior mañana? ¿Cuáles no cambiarían en absoluto?

## Soluciones

1. Eliminar `Kind` costó la abstracción genérica sobre efectos — sin
   `traverse` único, sin combinadores compartidos — y compró tipos legibles
   y mensajes de error, además de una API que un recién llegado puede usar
   sin aprender la codificación. Eliminar `Validated` costó un tipo
   acumulador dedicado y compró un único tipo de resultado en cada firma;
   el comportamiento de acumulación se movió a un scope, que es
   estrictamente más explícito en el punto de llamada.
2. FxTS puede guardar `map(f)` como un valor y pasarlo — los operadores son
   de primera clase, así que puedes construir una tubería dinámicamente a
   partir de una lista de etapas. FxDart obtiene tipos estáticos completos
   a lo largo de toda la cadena, incluida la inferencia dentro de los
   callbacks, que el `pipe` de FxTS solo logra a través de un muro de
   overloads escritos a mano.
3. `EitherT` generaliza: es un wrapper por mónada, así que un tercer efecto
   es otro transformer más en la pila (al costo de lifts en todas partes).
   `eitherAsync` no generaliza — FxDart escribe cada combinación útil a
   mano, y hay pocas, porque las combinaciones que la gente realmente usa
   son pocas.
4. El capítulo 10 habría que reescribirlo (trata *sobre* la ausencia), y la
   sección de "cuatro grafías" del capítulo 9 colapsaría a una sola. Los
   capítulos 1, 5, 6, 7, 8 y 19 no cambiarían en absoluto — las
   definiciones y leyes son neutrales al lenguaje, que es la razón entera
   por la que la teoría valía la pena aprenderla por separado de la
   librería.
