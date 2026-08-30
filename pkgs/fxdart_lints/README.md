# fxdart_lints

Analyzer lints for [fxdart](https://pub.dev/packages/fxdart). They fire on
the jobs the library exists to replace, so an agent that already runs the
analyzer is told — without having to load a skill.

The core `fxdart` package stays zero-dependency. This is a **dev**
dependency.

```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint

dev_dependencies:
  custom_lint: ^0.8.1
  fxdart_lints: ^0.8.10
```

| Lint | Flags | Does not flag |
|---|---|---|
| `avoid_unbounded_future_wait` | `Future.wait(xs.map(fetch))`, `Future.wait([for (x in xs) fetch(x)])` | `Future.wait([a, b, c])` |
| `avoid_bare_catch_in_raise` | `catch (` / `on Object` inside `either` / `nullable` / `foldRaise` | `on Exception`; `catching(...)` |
| `avoid_lazy_return_from_raise` | `return fx(xs).map(...)` from an `either` callback | `return fx(xs).toList()` / `.sequence()` / `.mapOrAccumulate(...)` |
| `attempt_after_retry` | `.attempt(...).retryOn(...)` | `.retryOn(...).attempt(...)` |

Each diagnostic names the fix. `attempt` after `retryOn`, never before:
those operators watch the error channel; a `Left` is not an error event.
