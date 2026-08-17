---
slug: laws
chapter: 0
part: 6
title: Appendix B · Law reference
description: Every law in the book on facing pages — what it says, what it licenses you to do, and how to test it.
---
# Appendix B · Law reference

Each law, in one line of code, with the refactor it permits. Everything here is
testable the way Chapter 19 tested it: generate inputs, assert the equation.

## Functor — Chapter 5

| Law | Equation |
|---|---|
| Identity | `m.map((x) => x)` == `m` |
| Composition | `m.map(f).map(g)` == `m.map((x) => g(f(x)))` |

**Licenses:** deleting a no-op `map`; fusing two `map`s into one pass;
splitting one `map` into two for readability.

**Breaks when:** `map` does anything besides apply the function — counting,
logging, caching, reordering (`Counted` in Chapter 5).

## Monad — Chapter 1

| Law | Equation |
|---|---|
| Left identity | `of(a).flatMap(f)` == `f(a)` |
| Right identity | `m.flatMap(of)` == `m` |
| Associativity | `m.flatMap(f).flatMap(g)` == `m.flatMap((x) => f(x).flatMap(g))` |

**Licenses:** inlining a wrapped value; deleting a no-op step; regrouping a
chain — which is what "extract this into a helper" does.

**Breaks when:** chaining itself has a cost the type records (`Logged` in
Chapter 1).

**Corollary:** `m.map(f)` == `m.flatMap((x) => of(f(x)))` — every lawful monad
is a lawful functor.

## Applicative — Chapter 6

| Law | Equation |
|---|---|
| Identity | `of(id).ap(m)` == `m` |
| Homomorphism | `of(f).ap(of(a))` == `of(f(a))` |
| Interchange | `u.ap(of(a))` == `of((f) => f(a)).ap(u)` |
| Composition | `of(compose).ap(u).ap(v).ap(w)` == `u.ap(v.ap(w))` |

In `map2` terms the useful consequence is: `map2` must run *both* structures
and combine them, never inspect one to decide about the other.

**Licenses:** running independent branches concurrently; accumulating their
failures; reordering independent branches (results combine the same way).

**Breaks when:** the "independent" branches secretly depend on each other —
shared mutable state in a validation branch is the usual culprit.

## Monoid / semigroup — Chapter 8

| Law | Equation |
|---|---|
| Associativity | `(a + b) + c` == `a + (b + c)` |
| Left identity | `empty + a` == `a` |
| Right identity | `a + empty` == `a` |

**Licenses:** chunking a fold; parallel or incremental reduction; using the
identity as a `fold` seed so the empty case is total.

**Breaks when:** the operation is subtraction-shaped, or the "identity" is
guessed from the type rather than the operation (`0` for multiplication).

**Not implied:** commutativity — `a + b` == `b + a` is a *separate*, stronger
law that most useful monoids lack.

## Traverse — Chapter 9

| Law | Statement |
|---|---|
| Identity | traversing with the identity applicative is `map` |
| Composition | traversing with two applicatives in sequence == traversing once with their composition |
| Naturality | a natural transformation commutes with `traverse` |

**Licenses:** choosing where to traverse in a chain; swapping fail-fast for
accumulating without touching the per-element function.

## Natural transformation — Chapter 20

| Law | Equation |
|---|---|
| Naturality | `α(m.map(f))` == `α(m).map(f)` |

**Licenses:** moving a conversion (`toList`, `toAsync`, `toNullable`, `first`)
across a `map`, in either direction.

**Breaks when:** the conversion inspects the values — `sortBy` is the standard
counterexample.

## Category — Chapter 20

| Law | Equation |
|---|---|
| Associativity | `(h ∘ g) ∘ f` == `h ∘ (g ∘ f)` |
| Identity | `id ∘ f` == `f` == `f ∘ id` |

**Licenses:** extracting or inlining any composition of pure functions,
including pipeline stages.

## The preconditions behind all of them

1. **Purity.** Every law above is stated over values; an effect makes two equal
   values into two different programs (Chapter 2).
2. **The right equality.** Structural for `Either` and `Money`; observational
   for `Future`; set-equality for `Set`. A law can hold under one and fail
   under another (Chapter 19).
3. **Someone checked.** A type's laws are a claim. Until there is a property
   test, they are a comment (Chapter 19).

## Testing template

```dart run
import 'package:fxdart/fxdart.dart';

// Generate → assert the equation → report. The seed is fixed so
// a failure can be reproduced exactly.
void main() {
  final rnd = createSeededRandom(7);
  final inputs = List.generate(100, (_) => (rnd() * 100).floor());

  Either<String, int> f(int n) =>
      n.isEven ? Either.right(n ~/ 2) : Either.left('odd');
  Either<String, int> g(int n) => Either.right(n + 1);

  var violations = 0;
  for (final x in inputs) {
    final m = Either<String, int>.right(x);
    if (m.map((v) => v) != m) violations++;
    final lifted = Either<String, int>.right(x);
    if (lifted.flatMap(f) != f(x)) violations++;
    if (m.flatMap(f).flatMap(g) !=
        m.flatMap((v) => f(v).flatMap(g))) {
      violations++;
    }
  }
  print('violations: $violations');
}
```
