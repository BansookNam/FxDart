# ParallelComparison cases

Five ways to run the *same* CPU-bound job, so the question "is `parallel`
worth it?" has a measured answer instead of a rule of thumb:

```
native.dart                 a plain loop, one isolate
native_isolate.dart         hand-rolled: slice the list, Isolate.run per slice
fxdart.dart                 fx(xs).map(work) — the chain, still one isolate
fxdart_parallel.dart        fx(xs).parallel(workers, work)      — the default
fxdart_parallel_chunk.dart  …parallel(workers, work, chunk: k)  — tuned
```

The last two are one row apart on purpose. `parallel` streams one element
per message by default, and that is what a reader writes first; `chunk:`
is the knob that decides whether the operator wins or loses on cheap
work. Showing only the tuned form would let the page assert something it
never demonstrates.

Every headline N is above the 10,000 the runner also measures at, or the
"full" block would come out smaller than the block above it — the trap
`AUTHORING.md` names for the other families, and it applies here too.

`native.dart` is the baseline every ratio is against, and it is sized to
run for **at least ~5 s**: below that the isolate spawn (~1 ms × workers)
and the port round trips are a large enough share of the total that the
numbers say more about the harness than about the work.

`work.dart` holds the per-element function, top-level and sendable, and
every variant calls that one function. That is the whole point — the only
thing that varies between the files is *where the work runs*, never what
it computes. `run` returns a checksum, and the runner refuses a case
whose checksums are not all identical.

The three cases differ on one axis, per-element cost, because that is
what decides the answer:

| case | items | per item | what it shows |
|---|---|---|---|
| `password-rehash` | 20,000 | ~250 µs | heavy work: `parallel` wins without tuning |
| `image-tiles` | 147,000 | ~37 µs | the middle: a chunk helps, clearly |
| `log-fingerprint` | 1,500,000 | ~3.5 µs | cheap work: chunk is the whole difference |

`log-fingerprint` is the case worth reading. Per element, the isolate
round trip (~5 µs) costs more than the work does, so `parallel` with the
default `chunk: 1` is *slower than the plain loop*. It is not a bad
operator there; it is being asked to pay a per-element price for a
per-element job. `chunk:` is the answer, and the page exists to make
that trade visible rather than folklore.

Run: `dart run benchmark/run_parallel_benchmarks.dart`
(`--smoke` for one un-warmed iteration while authoring).
