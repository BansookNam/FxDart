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

The reason more workers do not rescue it, measured at N=100,000 with
`BENCH_WORKERS` swept:

```
workers   .parallel()   .parallel(chunk:)
      1      768.8 ms            381.0 ms
      2      831.9 ms            191.1 ms
      5      899.1 ms             86.5 ms
     10      873.5 ms             71.0 ms
```

The unchunked form does not scale at all — it drifts slightly worse.
Every element costs two message copies, a port event and a completer *on
the main isolate*, which is one thread and the one part of the system
that cannot be parallelised: ~8 µs of coordination to hand off ~3.5 µs of
work, with the workers idle waiting to be fed. A batch does not make the
coordination cheaper, it makes there be less of it. `n ~/ (workers * 4)`
always yields 40 messages with ten workers: `chunk: 2500` at this
N=100,000 sweep (vs 100,000 round trips), `chunk: 37500` at the headline
N=1,500,000 (vs 1.5 million trips). This sweep is a separate
`BENCH_N=100000` / `BENCH_WORKERS` run; it is not in
`results-parallel.json`.

Run: `dart run benchmark/run_parallel_benchmarks.dart`
(`--smoke` for one un-warmed iteration while authoring).
