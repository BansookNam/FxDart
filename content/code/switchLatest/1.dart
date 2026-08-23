import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Starts its timers on listen, so a later inner is not already spent.
Stream<int> inner(int n) {
  final c = StreamController<int>();
  c.onListen = () {
    Timer(const Duration(milliseconds: 30), () {
      if (c.hasListener) c.add(n);
    });
    Timer(const Duration(milliseconds: 70), () {
      if (c.hasListener) c.add(n * 10);
      if (!c.isClosed) c.close();
    });
  };
  return c.stream;
}

Future<void> main() async {
  List<Stream<int>> twoInners() => [inner(1), inner(2)];

  print(await fxEvents(Stream.fromIterable(twoInners()))
      .switchLatest()
      .toList()); // [2, 20]
  // Second inner arrived while the first was still running — first
  // CANCELLED, so 1 and 10 never land.

  print(await fxEvents(Stream.fromIterable(twoInners()))
      .flattenConcat()
      .toList()); // [1, 10, 2, 20]
  // flattenConcat waits for each inner to finish; nothing is dropped.
  // flattenMerge would interleave both; exhaustLatest would ignore 2.
}
