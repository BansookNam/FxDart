# Arrow → Dart migration: blockers & deliberate deferrals

Status after the v0.6 typed-error core landed. Nothing here blocked the v0.6
scope itself — these are the Dart language limits that block *full* Arrow
parity, plus the features intentionally staged for later releases. Each entry
says why, and what the future plan is.

## Language-level blockers (cannot be fixed, only designed around)

### 1. No `inline` functions → sync/async APIs must be split
**Why it blocks:** Arrow's `either { }` is `inline`, so one builder serves both
plain and `suspend` blocks. Dart cannot inline a callback, and a sync function
cannot await, so one builder cannot serve both worlds.
**What we did:** `either`/`eitherAsync`, `foldRaise`/`foldRaiseAsync`,
`nullable`/`nullableAsync`, `catching`/`catchingAsync` — consistent with the
`op`/`opAsync` split fxdart already uses everywhere.
**Future plan:** none needed; this is permanent Dart reality. If Dart ever
gets macros able to abstract over asynchrony, revisit.

### 2. No receiver scoping (`Raise<E>.() -> A`) → explicit `r` parameter
**Why it blocks:** Kotlin blocks call `bind()`/`raise()` bare because the
`Raise` is the lambda receiver. Dart closures have no receivers and no
context parameters.
**What we did:** the scope is an explicit first parameter (`(r) { r.bind(x) }`),
and the whole vocabulary hangs off `r.` for discoverability — the same tax
`fx()` already pays versus FxTS's `pipe`.
**Future plan:** none; Dart has no proposal for context parameters.

### 3. A bare `catch (e)` can swallow the raise short-circuit signal
**Why it blocks:** the signal is a throw under the hood (same as Arrow). Kotlin
mitigates by subclassing `CancellationException`, which idiomatic Kotlin never
catches; Dart's `catch (e)` is untyped and catches everything.
**What we did:** the signal implements `Error` (so `on Exception` never sees
it), carries a diagnostic `toString()`, `catching`/`catchingAsync` rethrow it
before invoking handlers, and the pinned tests + docs teach the rule.
**Future plan:** a custom lint (separate `fxdart_lints` package, so the core
stays zero-dependency) that flags bare `catch` inside raise blocks.

### 4. Dart `Future`s cannot be cancelled → no structured-concurrency parity
**Why it blocks:** Arrow's `parZip`/`raceN` cancel losing/sibling coroutines on
failure. A Dart `Future` cannot be cancelled, so siblings always run to
completion; a raise in an unawaited branch can only surface as an unhandled
zone error (loud, but not cancellable).
**What we did (v0.6):** per-element scopes in `mapOrAccumulate(Async)` so a
raise can never cross elements; pinned tests for `Future.wait`'s error
behavior; docs say "raise only in the same awaited chain".
**Future plan (v0.7):** ship `parZip2..5` / `parZipOrAccumulate2..5` with the
documented divergence (fail-fast on throw, siblings run to completion,
results discarded).

### 5. Extension types are erased → `NonEmptyList` invariant is bypassable
**Why it blocks:** Kotlin's `value class NonEmptyList` cannot be forged without
opting into an `@PotentiallyUnsafeNonEmptyOperation` API. Dart extension types
erase to the representation, so `<int>[] as Nel<int>` succeeds — even empty.
**What we did:** constructors are the only sanctioned entry points; the
erasure semantics (including `==` being identity) are documented and pinned
by tests so a future language change is noticed.
**Future plan:** if Dart ever adds validated extension-type constructors or
non-erased wrappers with zero cost, tighten. Otherwise this stays a
compile-time-discipline type, exactly like Kotlin pre-1.5 inline classes.

### 6. No variadic generics → fixed arities
**Why it blocks:** Arrow generates `zipOrAccumulate` up to arity 9 (22 in the
high-arity artifact). Dart has neither variadic generics nor overloading.
**What we did:** `zipOrAccumulate2..5` (the `Curry2..Curry5` house precedent),
with `r.accumulate` as the unbounded primary API — so the arity cap costs
nothing expressible.
**Future plan:** extend to 9 only on concrete user demand.

## Deliberate deferrals (not blockers — staged scope)

| Feature | Target | Why deferred |
|---|---|---|
| `Effect`/`AsyncEffect` typedefs + combinators | v0.7 | Coherent as its own release; typed-error core is useful alone. |
| `parZip2..5`, `parZipOrAccumulate2..5` | v0.7 | Needs the cancellation-divergence docs (blocker #4). |
| `Resource`/`resourceScope`, `Semaphore` | v0.7 | Resource machinery unlocks Saga later; no v0.6 dependency. |
| `Schedule` + `retry`/`repeat`, `CircuitBreaker`, `Saga` | v0.8 | Pure addition on top of the core; Saga reuses Resource. |
| `Option`, `Ior` | on demand | Nullable-first policy; `T?` covers it until a nesting case appears. |
| Optics (+ codegen package) | future | Needs a separate `build_runner` generator package; large scope. |
| STM, collectors, latches/barriers, arities > 5 | not planned | No Dart-shaped demand; Arrow itself treats these as niche. |

Full design rationale: `plans/PLAN_v06.md` (local, not committed).
