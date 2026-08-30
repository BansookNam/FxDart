## 0.8.10

First release. Four lints that encode jobs fxdart exists to replace:

- `avoid_unbounded_future_wait`
- `avoid_bare_catch_in_raise` — bare / `on Object` / `on Error`, not specific `Exception` subtypes
- `avoid_lazy_return_from_raise` — `return` and `=>` raise callbacks; nested `map` closures are not the raise block
- `attempt_after_retry` — fxdart chains only
