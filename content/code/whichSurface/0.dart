import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<int> fetch(int id) async {
  await Future<void>.delayed(Duration.zero);
  return id * 10;
}

Future<void> main() async {
  // 1. Data in hand → fx(). Only the odds we ask for are computed.
  print(fx([1, 2, 3, 4, 5]).filter((n) => n.isOdd).take(2).toList());
  // [1, 3]

  // 2. I/O over a collection, at most 2 in flight, order kept.
  print(await fx([1, 2, 3]).mapConcurrent(2, fetch).toList());
  // [10, 20, 30]

  // 3. Values arrive when they arrive → fxEvents.
  print(await fxEvents(Stream.fromIterable(['f', 'fx', 'fxd']))
      .map((q) => 'q:$q')
      .toList());
  // [q:f, q:fx, q:fxd]

  // 4. The caller handles the failure → either.
  print(either<String, int>((r) {
    final n = r.ensureNotNull(int.tryParse('12'), () => 'bad');
    r.ensure(n > 0, () => 'not positive');
    return n;
  }));
  // Right(12)
}
