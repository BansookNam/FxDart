---
slug: reading
chapter: 0
part: 6
title: Appendix C · Further reading
description: Where to go next, with an honest note on each source's difficulty and what it is actually good for.
---
# Appendix C · Further reading

Ordered by how soon they are useful, with a plain note on difficulty. Nothing
here is required; every chapter of this book stands on its own.

## Inside this project

| Source | Good for | Difficulty |
|---|---|---|
| **FxDart 101 tutorials** | the API surface, one function at a time, with runnable demos | easy |
| **Dart vs FxDart** (52 examples) | whether a pipeline is the right tool for a given task, with verdicts | easy |
| **RxDart vs FxDart** | Chapter 12's pull/push decision, applied to 50 real problems | easy |
| **`WHY_CURRIED.md`** | the reasoning behind Chapter 4 — what a port owes its source | moderate |
| **`ARROW_MIGRATION_BLOCKER.md`** | the HKT wall of Chapter 10, documented as it was hit | moderate |
| **`benchmark/AUTHORING.md`** | how the Chapter 14 numbers are produced, and how to add a case | moderate |

## The ancestors' documentation

| Source | Good for | Difficulty |
|---|---|---|
| **Arrow (Kotlin) — typed errors guide** | Part IV's specification, effectively; the `Raise` scope, accumulation, and the design rationale | moderate |
| **FxTS docs** | the operator catalogue and `concurrent(n)`; names map onto FxDart almost exactly | easy |
| **Cats (Scala) — typeclass docs** | the tower stated generically: functor → applicative → monad → traverse | hard without Scala |
| **Haskell `Data.Functor` / `Control.Monad`** | the laws in their original form, tersely | hard |

## Papers and talks worth the time

- **Philip Wadler, *Monads for functional programming* (1992).** The paper that
  turned Moggi's semantics into a programming technique. Still the clearest
  motivation for why effects-as-values is worth doing. *Moderate; skip the
  Haskell syntax if it is unfamiliar and read the prose.*
- **Conor McBride & Ross Paterson, *Applicative programming with effects*
  (2008).** Where the applicative was named. Chapter 6 is a summary of its
  first three pages. *Moderate.*
- **Scott Wlaschin, *Railway Oriented Programming* (talk, 2014).** The picture
  Chapter 16 uses, presented well. *Easy — the best first talk on typed
  errors.*
- **Erik Meijer, *Subject/Observer is Dual to Iterator* (2010).** Chapter 12's
  duality, from the person who built Rx on it. *Moderate.*
- **Eugenio Moggi, *Notions of computation and monads* (1991).** The origin.
  *Hard — read it after Wadler, or not at all.*

## Books

- **Scott Wlaschin, *Domain Modeling Made Functional*.** Chapters 3, 16 and 18
  of this book, expanded into a whole practical method, in F#. The best single
  recommendation for a working developer. *Easy to moderate.*
- **Bartosz Milewski, *Category Theory for Programmers*.** Chapter 20 at
  length, free online, patient with beginners. *Moderate; the exercises are
  where the learning is.*
- **Runar Bjarnason & Paul Chiusano, *Functional Programming in Scala*.**
  Builds the whole tower from scratch as exercises. Excellent, and a serious
  time commitment. *Hard.*
- **Graham Hutton, *Programming in Haskell*.** If you decide to learn the
  source language, this is the gentlest complete route. *Moderate.*

## What to read for a specific question

| You want to know | Go to |
|---|---|
| "Which FxDart function does X?" | the 101 tutorials |
| "Should I use a pipeline here at all?" | Dart vs FxDart, and Chapter 22 |
| "How do I model this failure?" | Chapter 18, then Arrow's typed-errors guide |
| "Why is there no generic `traverse`?" | Chapter 10, then `ARROW_MIGRATION_BLOCKER.md` |
| "Is my type lawful?" | Chapter 19 and Appendix B, then write the property test |
| "What is a monad *really*?" | Chapter 1, then Wadler, then Chapter 20 |

## A closing note on how to read theory

The order that works is: **use it, name it, then formalise it.** Every chapter
in this book was written that way, and the sources above are best approached
the same way — find the construct you have already been using, read the section
that names it, and stop there until the next time you meet it.

Reading a theory book front to back without code in front of you is the
approach that produces the reputation, and it does not work.
