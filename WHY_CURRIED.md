# Why `.curried` (and not `curry`)

FxTS ships a `curry` function. fxdart ships a `.curried` extension getter
instead. This document explains why the direct port is impossible, how the
Dart-native replacement works, why it is named the way it is, and how the same
philosophy resolves the other "unportable" FxTS APIs.

```dart
int add(int a, int b) => a + b;

final addOne = add.curried(1); // int Function(int) — fully typed
addOne(2); // 3

fx([1, 2, 3]).map(multiply.curried(10)).toArray(); // [10, 20, 30]
```

## The problem: FxTS `curry` cannot be ported

FxTS's `curry` takes *any* function and returns a curried version of it,
whatever its arity:

```ts
const add = curry((a: number, b: number, c: number) => a + b + c);
add(1)(2)(3); // 6
add(1, 2)(3); // 6 — partial application at any split
```

It leans on two TypeScript/JavaScript capabilities:

1. **Runtime arity reflection** — JS functions expose `fn.length`, so `curry`
   can count parameters at runtime and decide when to stop collecting
   arguments and call the original.
2. **Recursive conditional types** — the `Curry<...>` type recursively peels
   parameters off a tuple type so the *compiler* knows `add(1)` is
   `(b: number) => (c: number) => number`.

Dart has neither. A Dart function value does not expose its parameter count
(`dart:mirrors` is dead on most platforms, including Flutter), and Dart's type
system has no variadic generics, no conditional types, and no function
overloads. A faithful one-function port is impossible — not merely awkward.

The first release of fxdart therefore shipped `curry` as a deprecated stub:
untyped (`Function` in, `Function` out), binary-only, existing purely so that
code migrating from FxTS gets an analyzer warning instead of silent breakage.
That left currying itself unresolved — this document is the resolution.

## The trick: static extension resolution as overloading

Dart lacks *function* overloading, but it has something that can stand in for
it: **extension applicability is resolved from the receiver's static type**.
Two extensions may declare a member with the same name on different `on`
types; at each call site the compiler picks whichever one matches — at
compile time, with full generic inference.

So instead of one function that reflects on arity at runtime, fxdart declares
one extension *per arity*, all exposing the same getter:

```dart
extension Curry2<A, B, R> on R Function(A, B) {
  R Function(B) Function(A) get curried => (a) => (b) => this(a, b);
}

extension Curry3<A, B, C, R> on R Function(A, B, C) {
  R Function(C) Function(B) Function(A) get curried =>
      (a) => (b) => (c) => this(a, b, c);
}
// ... Curry4, Curry5
```

A 2-parameter function only matches `Curry2`, a 3-parameter function only
matches `Curry3`, and so on — the "arity dispatch" that FxTS performs with
`fn.length` at runtime happens in the Dart *compiler* instead. The payoff is
that the result is fully typed, with zero casts:

```dart
String describe(String name, int age) => '$name is $age';

describe.curried;          // String Function(int) Function(String)
describe.curried('Alice'); // String Function(int)
```

Compare the deprecated stub, where everything collapsed to `Object?` and every
use site needed an `as` cast. The extension version is not a workaround with
worse ergonomics than the original — for reading code, it is arguably better,
because the curried type is spelled out in the IDE rather than computed by an
opaque conditional type.

## Why the name `curried`

Constraints on the name:

- It cannot be `curry` at the top level — that identifier is taken by the
  deprecated migration stub, and the two must coexist so FxTS code gets
  analyzer-guided migration (`@Deprecated('Use the .curried extension getter
  instead')`) rather than a breaking rename.
- Mangled spellings (`curryDart`, `curryD`, `curryTemp`, `curry2`) read as
  apologies. They permanently encode "this is the workaround" into every call
  site, and arity-suffixed names (`curry2`, `curry3`) leak an implementation
  detail the compiler already handles.

The getter form dissolves the conflict. As an extension *member*, the name
lives in a different namespace from the top-level function — but more
importantly, a getter wants a different part of speech. Dart's core libraries
name derived views of an object with past participles: `Iterable.reversed`,
`List.sorted(...)`, `String.split(...).reversed`. `fn.curried` follows that
convention exactly — it reads as "the curried form of `fn`", a *view*, which
is precisely what it returns. `fn.curry` would read as an imperative command;
`curry(fn)` was FxTS's spelling for a language that needed it.

There is precedent: [fpdart](https://pub.dev/packages/fpdart) exposes currying
through arity-specific extensions on function types, so Dart FP users will
find the pattern familiar.

## `uncurried`: the round trip

The inverse comes for free with the same trick, on *nested* function types:

```dart
extension Uncurry2<A, B, R> on R Function(B) Function(A) {
  R Function(A, B) get uncurried => (a, b) => this(a)(b);
}
```

This is genuinely useful beyond symmetry: hand-written curried closures (the
style the deprecated stub told you to write) can be flattened back into the
data-first shape that fxdart's operators expect:

```dart
final greet = (String greeting) => (String name) => '$greeting, $name!';
greet.uncurried('Hello', 'FxDart'); // 'Hello, FxDart!'
```

### The deepest-match rule

`uncurried` has one subtlety that `curried` does not. A 3-level chain
`A => B => C => R` matches both `Uncurry3` and `Uncurry2` (with the latter
seeing the result type as `C => R`). Dart's extension-specificity rules
resolve this by preferring the *most specific* applicable extension, which is
the deepest arity — so `.uncurried` always flattens the whole chain:

```dart
add3.curried.uncurried(1, 2, 3); // 6 — Uncurry3 wins
```

To flatten fewer levels, apply the extension explicitly — standard Dart
syntax for overriding extension resolution:

```dart
Uncurry2(add3.curried).uncurried(1, 2)(3); // (A, B) => C => R
```

## What the extension approach cannot do

Honesty section. Compared with FxTS `curry`:

- **No mixed application.** FxTS allows `add(1, 2)(3)`. `.curried` produces a
  strictly unary chain: `add.curried(1)(2)(3)`. Supporting every split would
  require one member per *split pattern* — possible, but it multiplies API
  surface for a style `pipe`/`fx()` composition rarely needs.
- **Fixed maximum arity.** Extensions are declared for arities 2–5. Each new
  arity is three mechanical lines; 5 covers practical use (a 6-ary function
  has bigger problems than currying).
- **Positional parameters only.** A function type with named or optional
  parameters is not a subtype of the plain positional `on` type, so `.curried`
  does not appear on it. This matches FxTS, where currying is positional by
  definition.
- **Static types required.** A value typed as bare `Function` (post-erasure,
  e.g. from `Function.apply` plumbing) matches no extension. Currying is a
  static-composition tool; if the type is already erased, a closure is the
  right spelling anyway.

## The same philosophy, applied to the rest

`curry` was the last unresolved entry on the unportable list, but the shape of
the resolution — **port the meaning, not the spelling** — is the same one the
other entries already follow. Each keeps a `@Deprecated` stub for
analyzer-guided migration, with a Dart-native replacement that says what it
actually does in this language:

| FxTS API | Why it can't port literally | fxdart replacement |
|---|---|---|
| `curry(f)` | needs arity reflection + recursive conditional types | `.curried` / `.uncurried` extension getters |
| `isUndefined` | Dart has no `undefined`, only `null` | `isNull` |
| `isArray` | JS `Array` is Dart `List` | `isList` |
| `isObject` | JS plain-object semantics don't exist; closest analogue is `Map` | `isMap` |
| `takeUntil` | name deprecated upstream in FxTS itself (inclusive semantics were surprising) | `takeUntilInclusive` |

The predicates follow Dart's type names because a predicate's name *is* its
contract — `isArray` returning true for a `List` would be a lie about which
language you're in. `takeUntilInclusive` follows FxTS's own deprecation, with
the honest name. And `curry` becomes `curried` because in Dart the natural
home for function-shape transformations is an extension getter on the function
type itself.

### Migration cheat-sheet

```dart
// FxTS style (deprecated stubs — analyzer will flag these):
final f = curry((int a, int b) => a + b);   // untyped Function
isUndefined(x);
isArray(x);
isObject(x);
takeUntil(predicate, iterable);

// fxdart style:
final f = ((int a, int b) => a + b).curried; // int Function(int) Function(int)
isNull(x);
isList(x);
isMap(x);
takeUntilInclusive(predicate, iterable);
```
