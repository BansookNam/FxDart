---
slug: glossary
chapter: 0
part: 6
title: Apéndice A · Glosario
description: Cada término que define este libro, con sus alias, su grafía en Dart y el capítulo que lo presenta.
---
# Apéndice A · Glosario

Cada término en negrita del libro, con los nombres que recibe en otros sitios
y el lugar donde se escribe en Dart. El número de capítulo es donde se
presenta.

## La torre

| Término | También llamado | En Dart / FxDart | Cap. |
|---|---|---|---|
| **Functor** | — | cualquier tipo con un `map` legal | 5 |
| **Applicative** | functor aplicativo | `map2`, `zipOrAccumulate`, `Future.wait` | 6 |
| **Mónada** | — | cualquier tipo con `of` + un `flatMap` legal | 1 |
| **Monoide** | — | una semilla de `fold` más una combinación asociativa | 8 |
| **Semigrupo** | — | combinación asociativa, sin identidad — `Nel` | 8 |
| **Recorrible** | Traversable | `sequence`, `mapOrAccumulate`, `Future.wait` | 9 |
| **Composición de Kleisli** | composición monádica, `>=>` | `(a) => f(a).flatMap(g)` | 7 |
| **Transformación natural** | — | una conversión genérica que ignora el contenido | 20 |
| **Tipo de orden superior** | HKT, polimorfismo de constructores de tipos | *no expresable en Dart* | 10 |

## Operaciones

| Término | También llamado | En Dart / FxDart | Cap. |
|---|---|---|---|
| **of** | `pure`, `return`, `unit`, η | `Either.right`, `[x]`, `Future.value`, `fx([x])` | 1 |
| **map** | `fmap`, `<$>` | `map`, `Future.then` | 5 |
| **flatMap** | `bind`, `>>=`, `chain` | `flatMap`, `expand`, `Future.then`, `r.bind` | 1 |
| **join** | `flatten`, μ | `flat()`, `expand(id)` | 20 |
| **map2** | `zipWith`, `liftA2` | `map2`, `zipOrAccumulate2` | 6 |
| **traverse** | — | `mapOrAccumulate`, `.map(f).sequence()` | 9 |
| **sequence** | — | `sequenceEither`, `Future.wait` | 9 |
| **fold** | catamorfismo, `reduce` con semilla | `fold`, `Either.fold` | 8 |

## Evaluación

| Término | También llamado | En Dart / FxDart | Cap. |
|---|---|---|---|
| **Perezoso** | diferido, no estricto | cualquier etapa `Fx` — nada se ejecuta hasta un terminal | 11 |
| **Operador terminal** | consumidor, sumidero | `toList`, `each`, `fold`, `first`, `sum` | 11 |
| **Pull** | interactivo, con forma de `Iterable` | `Iterable`, `FxAsyncIterable` | 12 |
| **Push** | reactivo, observable | `Stream`, `FxEvents` | 12 |
| **Contrapresión** | control de flujo | no pedir el siguiente valor | 12 |
| **Fusión** | fusión de etapas, deforestación | una sola pasada por toda una cadena | 5 |
| **Concurrencia** | — | `concurrent(n)`, `mapConcurrent` — esperas solapadas | 13 |
| **Paralelismo** | — | isolates — *cómputo* solapado | 13 |

## Fallo

| Término | También llamado | En Dart / FxDart | Cap. |
|---|---|---|---|
| **Either** | `Result`, `Validation`, unión disjunta | `Either<L, R>`, `Left`, `Right` | 16 |
| **Ámbito Raise** | ámbito de receptor de contexto, ámbito de efecto | `either((r) { … })`, `r.bind`, `r.ensure` | 15 |
| **Continuación delimitada** | `shift`/`reset`, manejador de efectos | la salida no local dentro de `either` | 15 |
| **Cortocircuito** | fallo rápido | el primer `Left` termina la cadena | 16 |
| **Acumulación** | fallo lento, validación aplicativa | `accumulate`, `zipOrAccumulate`, `mapOrAccumulate` | 17 |
| **NonEmptyList** | `Nel` | `NonEmptyList<E>` — extension type sobre `List` | 8 |
| **Transformador de mónadas** | `EitherT`, `OptionT` | *no se usa* — en su lugar, `eitherAsync` | 7 |

## Fundamentos

| Término | También llamado | En Dart / FxDart | Cap. |
|---|---|---|---|
| **Función pura** | — | mismas entradas, misma salida, nada observable | 2 |
| **Transparencia referencial** | sustituibilidad | reemplazar una llamada por su resultado | 2 |
| **Efecto** | efecto secundario | cualquier cosa observable además del valor de retorno | 2 |
| **Función total** | — | definida para toda entrada — `fold` lo es, `reduce` no | 8 |
| **Tipo producto** | record, tupla, struct | `(A, B)`, campos de una clase | 3 |
| **Tipo suma** | unión etiquetada, variante, coproducto | `sealed class` + `switch` | 3 |
| **Tipo de dato algebraico** | ADT | sumas y productos juntos | 3 |
| **Currificación** | — | `.curried` / `.uncurried` | 4 |
| **Aplicación parcial** | — | un closure que captura algunos argumentos | 4 |
| **Función de orden superior** | — | toma o devuelve una función | 4 |
| **Razonamiento ecuacional** | — | reemplazar iguales por iguales, según una ley | 19 |
| **Ley** | propiedad, contrato | una ecuación que las instancias deben cumplir | 1, 5, 8 |
| **Categoría** | — | objetos + flechas componibles + identidades | 20 |

## Nombres que significan lo mismo

Un breve decodificador para la lectura entre lenguajes:

- `flatMap` = `bind` = `>>=` = `chain` = `SelectMany` (C#) = `expand` (el
  `Iterable` de Dart).
- `of` = `pure` = `return` = `unit` = `just` = `Right` = `Future.value`.
- `map` = `fmap` = `<$>` = `Select` (C#) = `then` (el `Future` de Dart, que
  también es su `flatMap`).
- `Either<E, A>` = `Result<A, E>` (Rust — nótese los parámetros invertidos) =
  `Validation` (cuando el applicative acumula).
- `NonEmptyList` = `Nel` = `NonEmptyChain` (Cats).
