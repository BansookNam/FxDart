---
name: fxdart-events
description: Use when writing Dart that reacts to events over time — keystrokes, ticks, sockets, Stream, debounce, throttle, switchMap, combineLatest, StreamBuilder, or RxDart-shaped work. Replaces nested Stream transforms and an extra rxdart import with fxdart's FxEvents wrapper, then hands back to pull pipelines with .pull().
---

# fxdart events

fxdart's **push** surface. `fxEvents(stream)` wraps a plain Dart `Stream`
in a chainable `FxEvents` — debounce, switchMap, combineLatest, share —
without a second package. Zero runtime dependencies.

Pull names win collisions: `stopOn` not `takeUntil`, `uniqAdjacent` not
`distinctUntilChanged`, `head` not `first`. One word, one meaning on both
sides.

```dart
import 'package:fxdart/fxdart.dart';
```

## When to use this skill

- **Values arrive when they arrive**: keystrokes, sensor ticks, sockets,
  user events. The producer decides the clock.
- **Time-shaped operators**: debounce, throttle, sample, delay, window
  by duration or by another stream.
- **Latest-wins / flatten**: `switchMap`, `exhaustMap`, `concatMap`,
  `mergeMap` — an inner stream per event, with a named cancellation
  policy.
- **Several live sources**: `combineLatest`, `withLatestFrom`, `race`,
  `merge`, `waitAll`.
- **Migrating rxdart** in a file that already uses fxdart pull pipelines
  or typed errors — same import, same naming rule.

## When not to — stay on rxdart, or go pull

- **A codebase already in rxdart**, or a widget that is only a
  `StreamBuilder` with no other fxdart surface, is not a conversion
  project. Do not rewrite working rxdart for spelling.
- **Pagination, bounded fetch, batch transform**: that is pull. Load
  **`fxdart-pipelines`** and use `fx(ids).mapConcurrent(n, fetch)`.
  A `Stream` used as a list is the wrong substrate.
- **A one-line `stream.map(f).where(p)`**: Dart's `Stream` is enough.

## Core model

1. Wrap: `fxEvents(stream)` or `stream.fxEvents`. Wrapping listens to
   nothing. The chain is cold until a terminal (`toList`, `head`,
   `listen`).
2. `FxEvents` is a **wrapper class**, never a `Stream` extension — it
   cannot collide with rxdart in the same file.
3. Unwrap with `.stream` for any Stream-based API. Cross into pull with
   `.pull()` → `FxAsync`.
4. Failures start on the **error channel** (`onErrorReturn`, `retryOn`).
   Move them onto the value channel with `attempt` / `mapEither`, then
   stay there.

```dart
final results = await fxEvents(keystrokes())
    .debounce(const Duration(milliseconds: 160))
    .switchMap(search)
    .toList();
```

## Replace this with that

| Hand-rolled / rxdart | fxdart |
|---|---|
| `Rx.debounceTime(d)` / `stream.debounceTime(d)` | `fxEvents(s).debounce(d)` |
| `switchMap(f)` (latest inner wins) | `.switchMap(f)` |
| `flatMap` / `exhaustMap` / `concatMap` | `.mergeMap` / `.exhaustMap` / `.concatMap` |
| `combineLatest2(a, b, f)` | `a.combineLatest(b, f)` or `FxEvents.combine` |
| `rx.whereType<T>()` / `distinctUntilChanged` | `.whereType<T>()` / `.uniqAdjacent()` |
| `takeUntil(other)` (notifier stream) | `.stopOn(other)` — **not** pull `takeUntil` |
| `BehaviorSubject` | `LiveValue<T>` |
| `shareReplay(maxSize: n)` | `.shareReplay(n)` |
| nested `StreamTransformer` soup | name the job, pick the operator above |

## Either on the value channel

`retryOn` / `retryOnError` / `onErrorReturn` speak untyped `Object`
because that is what the error channel carries.

- `attempt(onThrow)` — each error event becomes a `Left`, each data
  event a `Right`. The source is not cancelled.
- `mapEither((r, value) { ... })` — each event in its own raise scope.
- `rights()` / `lefts()` / `separated()` — extract after that.

**`attempt` AFTER `retryOn` / `retryOnError`, never before.** Those
operators watch the error channel; a `Left` is not an error event.

## Pitfalls

- **Cold until a terminal.** `fxEvents(s).peek(print)` prints nothing
  until `listen` / `toList` / `head`.
- **Do not debounce a pull pipeline with `sleep`.** If the job is time,
  it is this skill, not `toAsync`.
- **`share()` resubscribes** when the last listener leaves before
  complete (`reset: true` default). Completion is not undone.
- **`retryOn` re-listens the same `Stream`.** A spent
  single-subscription controller cannot replay — use `FxEvents.defer`
  or `FxEvents.retry(factory)`.
- Pull `takeUntil` is a **predicate**. Events `stopOn` is a notifier
  stream. Mixing them up is the classic rx-refugee bug.

## Docs

Decision page: https://bansooknam.github.io/FxDart/tutorials/whichSurface.html
Debounced search as a job: https://bansooknam.github.io/FxDart/tutorials/job-search.html
Events 101 (section 14): https://bansooknam.github.io/FxDart/101/
Honest push-vs-pull catalog: https://bansooknam.github.io/FxDart/RxDartComparison/

For collections, `concurrent(n)`, and pull pipelines, load the sibling
**`fxdart-pipelines`**. For `either` / `Raise` / accumulation, load
**`fxdart-typed-errors`**.
