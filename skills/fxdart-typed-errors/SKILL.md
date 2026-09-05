---
name: fxdart-typed-errors
description: Use when writing Dart error handling: functions that can fail with domain errors, validation that should report every problem (not just the first), replacing exceptions-as-control-flow or null-with-no-reason returns, or migrating fpdart/dartz Either/TaskEither code. fxdart's Raise/either gives typed errors as straight-line code — no flatMap chains, no wrapper types.
---

# fxdart typed errors

fxdart ports the **approach of Kotlin Arrow 2.x** to Dart: a
`Raise<E>` scope in which straight-line code can short-circuit with a
*typed* error. `Either` appears only at function boundaries — never as a
wrapper you `flatMap` through. Zero runtime dependencies; requires
Dart SDK ≥ 3.3.

```dart
import 'package:fxdart/fxdart.dart';
```

## When to use this skill

- **Functions that can fail for domain reasons** (parse, validate, look up,
  authorize): return `Either<Failure, T>` built with `either((r) { ... })`
  instead of throwing, returning `null` with the reason lost, or returning
  bool + out-param shapes.
- **Validation that should collect EVERY error** — form/config/record
  validation where "first error only" is a bad UX. This is
  `r.accumulate` / `r.zipOrAccumulate2..5` / `mapOrAccumulate`; plain Dart
  and fpdart have no equivalent (fpdart's Either is fail-fast only).
- **Bulk validation with concurrency**: "validate N records, K at a time,
  keep every failure in input order" — `mapOrAccumulate(..., concurrency: k)`
  on an async chain.
- **Migrating fpdart/dartz code**: `TaskEither`/`IO`/`Do`-notation towers
  flatten into `eitherAsync` blocks (see the table below).

## When plain Dart wins — do NOT wrap these

- **Truly exceptional failures** (bugs, I/O the caller can't act on):
  keep throwing. Typed errors are for failures the caller *handles*.
- **Simple absence with no reason to carry**: return `T?`. fxdart is
  nullable-first; there is deliberately no `Option` type. Use the
  `nullable((r) { ... })` builder only when several nullable steps chain.
- **A single fallible step**: `int.tryParse(s) ?? defaultValue` needs no
  scope. The builder earns its keep at two-plus dependent steps.

## Core model

`either((r) { ... })` runs your block with a scope `r`. Inside, everything
is ordinary Dart — early returns, loops, `if`s. Any raise short-circuits
the block; the builder returns `Right(value)` or `Left(error)`.

```dart
Either<String, int> parsePort(String raw) => either((r) {
  final n = r.ensureNotNull(int.tryParse(raw), () => '"$raw" is not a number');
  r.ensure(n > 0 && n < 65536, () => '$n is out of range');
  return n;
});

// Consume with an exhaustive switch — sealed, no default needed:
switch (parsePort(input)) {
  case Right(:final value): listen(value);
  case Left(:final value):  log('bad config: $value');
}
```

The scope vocabulary (type `r.` to discover it):

- `r.bind(either)` — unwrap a `Right` or short-circuit with the `Left`.
  Kotlin's `either { x.bind() }` becomes `either((r) { r.bind(x) })`.
- `r.bindAll(eithers)` — unwrap a whole collection, first `Left` wins.
- `r.ensure(cond, () => err)` — typed-error `require`.
- `r.ensureNotNull(x, () => err)` — returns non-null (promotion works).
- `r.raise(err)` — short-circuit directly; returns `Never`.
- `r.recover(block, onRaise)` — handle a raised error in a nested scope.
- `r.withError(transform, block)` — adapt a different error type into this
  scope (compose modules with different Failure types).

Async is the same shape with `eitherAsync((r) async { ... })`; the
nullable-first twins are `nullable`/`nullableAsync` (return `T?`).

```dart
Future<Either<Failure, SuccessData>> getResult() => eitherAsync((r) async {
  final user  = r.bind(await findUser(userId));
  final order = r.bind(await findOrder(user.id));
  return SuccessData(user, order);
});
```

## Accumulation — collect every failure

The Arrow replacement for `Validated`. Error side is
`NonEmptyList<E>` (`Nel<E>`), a zero-cost extension type that cannot be
empty. All branches run; errors concatenate in order; failure happens at
the end.

```dart
final user = either<Nel<String>, User>((r) => r.zipOrAccumulate2(
  (r) => validateName(r, input),   // each branch gets its own scope
  (r) => validateAge(r, input),
  User.new,
));

// Unbounded form — combine any number of branches:
final user = either<Nel<String>, User>((r) => r.accumulate((acc) {
  final name = acc.accumulating((r) => validateName(r, input));
  final age  = acc.accumulating((r) => validateAge(r, input));
  return User(name.value, age.value);   // reads detonate if anything failed
}));

// Whole-collection validation (fail-slow):
final parsed = either<Nel<String>, List<int>>((r) =>
    r.mapOrAccumulate(rawInputs, (r, s) =>
        r.ensureNotNull(int.tryParse(s), () => 'bad: $s')));
```

Bridges: `someEither.toEitherNel()` lifts a fail-fast value into an
accumulating scope; `r.bindNel(eitherNel)` raises all of its errors at once.

## Pipeline integration (works with fxdart chains)

Eager `Either`-aware terminals on `fx()`/async chains:

```dart
final (failures, oks) = fx(results).separated();   // (List<L>, List<R>)
fx(results).rights();                              // List<R>
fx(results).sequence();                            // Either<L, List<R>> — fail-fast
                                                   // (async: stops pulling at first Left)

// Fail-slow concurrent validation, ordered, every failure kept:
final outcome = await fxStream(records)
    .mapOrAccumulate<String, User>((r, rec) async {
  final parsed = r.ensureNotNull(tryParse(rec), () => 'bad record: $rec');
  return await enrich(parsed);
}, concurrency: 8);
```

## Exceptions vs raised errors — a hard boundary

Raised errors are domain failures; thrown exceptions are defects and
propagate out of `either` untouched. Capture a throw explicitly:

```dart
Either.catching(() => jsonDecode(raw));                    // Either<Object, T>
Either.catchingWith(ParseFailure.new, () => jsonDecode(raw)); // typed Left
catching(() => risky(), (e, st) => fallback);              // value-level
```

`catching`/`catchingAsync`/`Either.catching` always rethrow the internal
short-circuit signal first — they are the sanctioned `catch` inside raise
blocks.

## Replace this with that

| Hand-rolled / fpdart pattern | fxdart |
|---|---|
| `throw`/`try`/`catch` as control flow for expected failures | `either((r) { ... r.raise(err) ... })` |
| Return `null` with the failure reason lost | `Either<Failure, T>` via `either` |
| `e1.flatMap((a) => e2.flatMap((b) => ...))` pyramid | `either((r) { final a = r.bind(e1); final b = r.bind(e2); ... })` |
| fpdart `TaskEither.tryCatch(...).flatMap(...)` chains | `eitherAsync((r) async { ... })` + `Either.catchingWith` |
| fpdart `Either.Do(($) => $(x))` (footgun-laden) | `either((r) => r.bind(x))` — scope-tagged, nesting-safe |
| Loop collecting error strings + flag variable | `r.mapOrAccumulate` / `r.accumulate` |
| `if (a == null \|\| b == null) return null;` cascades | `nullable((r) { r.bind(a); r.bind(b); ... })` |

## Pitfalls

- **Never return a LAZY pipeline from a raise block.** `either((r) =>
  fx(xs).map((x) => r.bind(...)))` returns `Right(<unevaluated>)` and the
  deferred raise throws `RaiseLeakedError` at the distant consumption site.
  Materialize with `toList()` inside the block, or use the eager terminals
  (`sequence`, `mapOrAccumulate`).
- **Never bare-`catch` inside a raise block** — `catch (e)` swallows the
  short-circuit signal (pinned behavior). Use `catching`/`catchingAsync`.
  `on Exception` is already safe: the signal is an `Error`.
- **Async: raise only in the same awaited chain.** A raise inside an
  unawaited future can't be captured — it surfaces as an unhandled zone
  error (alive scope) or `RaiseLeakedError` (dead scope). Inside
  `Future.wait`, a second branch's raise is silently dropped (first error
  wins). Per-element scopes (`mapOrAccumulate`) avoid all of this.
- **`Either` equality is shallow**: `Right([1,2]) == Right([1,2])` is false
  (list identity). In tests compare `.getOrNull()`/`.leftOrNull()` contents.
- **`Nel` is erased at runtime** (extension type): `<int>[] as Nel<int>`
  succeeds — even empty. Construct only via `NonEmptyList.of` /
  `NonEmptyList.orNull`; `==` is identity, use `deepEquals`.
- **Error-type inference needs help at the boundary**: write
  `either<Failure, int>((r) { ... })` when the block body doesn't pin `E`.
- **Exceptions beat accumulation**: a branch that *throws* aborts the whole
  accumulating scope and propagates. That is the contract, not a bug.

## Events-layer Either (push)

On `FxEvents`, failures start on Dart's untyped error channel.
`retryOn` / `retryOnError` / `onErrorReturn` speak that channel.

- `attempt(onThrow)` — error event → `Left`, data event → `Right`.
- `mapEither((r, value) { ... })` — each event in its own raise scope.
- `rights()` / `lefts()` / `separated()` — extract after that.

**`attempt` AFTER `retryOn` / `retryOnError`, never before.** Those
operators watch the error channel; a `Left` is not an error event. The
same laziness rule applies: never return a lazy pipeline from a raise
block on this surface either.

## Docs

Guide with the Kotlin-Arrow comparison:
https://bansooknam.github.io/FxDart/tutorials/typedErrors.html
Decision page:
https://bansooknam.github.io/FxDart/tutorials/whichSurface.html
Bounded fetch as a job:
https://bansooknam.github.io/FxDart/tutorials/job-fetch.html
For pipelines, concurrency, and the operator catalog, see the sibling
`fxdart-pipelines` skill. For debounce / switchMap / time, see
`fxdart-events`.
