---
slug: glossary
chapter: 0
part: 6
title: Appendix A · Glossary
description: Every term this book defines, with its aliases, its Dart spelling, and the chapter that introduces it.
---
# Appendix A · Glossary

Every bolded term in the book, with the names it goes by elsewhere and the
place it is spelled in Dart. The chapter number is where it is introduced.

## The tower

| Term | Also called | In Dart / FxDart | Ch. |
|---|---|---|---|
| **Functor** | — | any type with a lawful `map` | 5 |
| **Applicative** | applicative functor | `map2`, `zipOrAccumulate`, `Future.wait` | 6 |
| **Monad** | — | any type with `of` + lawful `flatMap` | 1 |
| **Monoid** | — | a `fold` seed plus an associative combine | 8 |
| **Semigroup** | — | associative combine, no identity — `Nel` | 8 |
| **Traversable** | — | `sequence`, `mapOrAccumulate`, `Future.wait` | 9 |
| **Kleisli composition** | monadic composition, `>=>` | `(a) => f(a).flatMap(g)` | 7 |
| **Natural transformation** | — | a generic conversion that ignores contents | 20 |
| **Higher-kinded type** | HKT, type constructor polymorphism | *not expressible in Dart* | 10 |

## Operations

| Term | Also called | In Dart / FxDart | Ch. |
|---|---|---|---|
| **of** | `pure`, `return`, `unit`, η | `Either.right`, `[x]`, `Future.value`, `fx([x])` | 1 |
| **map** | `fmap`, `<$>` | `map`, `Future.then` | 5 |
| **flatMap** | `bind`, `>>=`, `chain` | `flatMap`, `expand`, `Future.then`, `r.bind` | 1 |
| **join** | `flatten`, μ | `flat()`, `expand(id)` | 20 |
| **map2** | `zipWith`, `liftA2` | `map2`, `zipOrAccumulate2` | 6 |
| **traverse** | — | `mapOrAccumulate`, `.map(f).sequence()` | 9 |
| **sequence** | — | `sequenceEither`, `Future.wait` | 9 |
| **fold** | catamorphism, `reduce` with seed | `fold`, `Either.fold` | 8 |

## Evaluation

| Term | Also called | In Dart / FxDart | Ch. |
|---|---|---|---|
| **Lazy** | deferred, non-strict | any `Fx` stage — nothing runs until a terminal | 11 |
| **Terminal operator** | consumer, sink | `toList`, `each`, `fold`, `first`, `sum` | 11 |
| **Pull** | interactive, `Iterable`-shaped | `Iterable`, `FxAsyncIterable` | 12 |
| **Push** | reactive, observable | `Stream`, `FxEvents` | 12 |
| **Backpressure** | flow control | not asking for the next value | 12 |
| **Fusion** | stage fusion, deforestation | one pass through a whole chain | 5 |
| **Concurrency** | — | `concurrent(n)`, `mapConcurrent` — overlapping waits | 13 |
| **Parallelism** | — | isolates — overlapping *computation* | 13 |

## Failure

| Term | Also called | In Dart / FxDart | Ch. |
|---|---|---|---|
| **Either** | `Result`, `Validation`, disjoint union | `Either<L, R>`, `Left`, `Right` | 16 |
| **Raise scope** | context receiver scope, effect scope | `either((r) { … })`, `r.bind`, `r.ensure` | 15 |
| **Delimited continuation** | `shift`/`reset`, effect handler | the non-local exit inside `either` | 15 |
| **Short-circuit** | fail-fast | the first `Left` ends the chain | 16 |
| **Accumulation** | fail-slow, applicative validation | `accumulate`, `zipOrAccumulate`, `mapOrAccumulate` | 17 |
| **NonEmptyList** | `Nel` | `NonEmptyList<E>` — extension type over `List` | 8 |
| **Monad transformer** | `EitherT`, `OptionT` | *not used* — `eitherAsync` instead | 7 |

## Foundations

| Term | Also called | In Dart / FxDart | Ch. |
|---|---|---|---|
| **Pure function** | — | same inputs, same output, nothing observable | 2 |
| **Referential transparency** | substitutability | replacing a call with its result | 2 |
| **Effect** | side effect | anything observable besides the return value | 2 |
| **Total function** | — | defined for every input — `fold` is, `reduce` is not | 8 |
| **Product type** | record, tuple, struct | `(A, B)`, class fields | 3 |
| **Sum type** | tagged union, variant, coproduct | `sealed class` + `switch` | 3 |
| **Algebraic data type** | ADT | sums and products together | 3 |
| **Currying** | — | `.curried` / `.uncurried` | 4 |
| **Partial application** | — | a closure capturing some arguments | 4 |
| **Higher-order function** | — | takes or returns a function | 4 |
| **Equational reasoning** | — | replacing equals with equals, by law | 19 |
| **Law** | property, contract | an equation instances must satisfy | 1, 5, 8 |
| **Category** | — | objects + composable arrows + identities | 20 |

## Names that mean the same thing

A short decoder for cross-language reading:

- `flatMap` = `bind` = `>>=` = `chain` = `SelectMany` (C#) = `expand` (Dart's
  `Iterable`).
- `of` = `pure` = `return` = `unit` = `just` = `Right` = `Future.value`.
- `map` = `fmap` = `<$>` = `Select` (C#) = `then` (Dart's `Future`, which is
  also its `flatMap`).
- `Either<E, A>` = `Result<A, E>` (Rust — note the flipped parameters) =
  `Validation` (when the applicative accumulates).
- `NonEmptyList` = `Nel` = `NonEmptyChain` (Cats).
