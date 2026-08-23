import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sum = await fxEvents(Stream.fromIterable([1, 2, 3]))
      .mergeScan<int>(10, (acc, x) => Stream.value(acc + x))
      .toList();
  print(sum); // [11, 13, 16]
  // Seed 10 is the starting accumulator — it is NOT an event.

  final empty = await fxEvents(const Stream<int>.empty())
      .mergeScan<int>(10, (acc, x) => Stream.value(acc + x))
      .toList();
  print(empty); // [] — empty source, seed stays silent

  final scanned = await fxEvents(Stream.fromIterable([1, 2, 3]))
      .scan((acc, x) => acc + x, 10)
      .toList();
  print(scanned); // [10, 11, 13, 16]
  // FxEvents.scan DOES emit the seed first. That is the difference.
}
