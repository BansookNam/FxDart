import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Emits each (offsetMs, value) pair at its offset, closing at [closeMs].
Stream<T> timed<T>(List<(int, T)> events, int closeMs) {
  final c = StreamController<T>();
  for (final (ms, v) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(v));
  }
  Timer(Duration(milliseconds: closeMs), c.close);
  return c.stream;
}

Future<void> main() async {
  // Exercise 1: concatMap keeps inner streams strictly in order.
  final pages = await fxEvents(Stream.fromIterable([1, 2, 3]))
      .concatMap((n) => timed([(120, 'page $n')], 150))
      .toList();
  print(pages); // [page 1, page 2, page 3] — one at a time, ~450ms

  // Exercise 2: mergeMap with a concurrency cap — four jobs, two at a
  // time. Source order decides who STARTS; completion decides who is
  // emitted first.
  final jobs = await fxEvents(Stream.fromIterable([1, 2, 3, 4]))
      .mergeMap((n) => timed([(120, 'job $n')], 150), concurrent: 2)
      .toList();
  print(jobs); // [job 1, job 2, job 3, job 4] — in two waves

  // The four policies, in one line each:
  //   mergeMap   — run them all, interleaved
  //   concatMap  — run them one after another, in order
  //   switchMap  — keep only the newest, cancel the rest
  //   exhaustMap — keep only the first, ignore the rest
}
