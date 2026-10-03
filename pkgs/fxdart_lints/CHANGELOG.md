## 0.9.0

Follows fxdart 0.9.0's `fx` prefix on short top-level functions: the raise
scopes recognised by `avoid_bare_catch_in_raise` and
`avoid_lazy_return_from_raise` are now `fxEither`, `fxEitherAsync`,
`fxEitherCatching`, `fxEitherCatchingAsync`, `fxNullable`,
`fxNullableAsync`, `fxFoldRaise` and `fxFoldRaiseAsync`, and the diagnostic
text suggests `fxCatching(...)` / `fxEitherCatching`.

## 0.8.10

First release. Four lints that encode jobs fxdart exists to replace:

- `avoid_unbounded_future_wait`
- `avoid_bare_catch_in_raise` — bare / `on Object` / `on Error`, not specific `Exception` subtypes
- `avoid_lazy_return_from_raise` — `return` and `=>` raise callbacks; nested `map` closures are not the raise block
- `attempt_after_retry` — fxdart chains only
