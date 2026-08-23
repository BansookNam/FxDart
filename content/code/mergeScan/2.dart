import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A finite tree: each node emits the next, and 2 is a leaf.
  //   0 → 1 → 2
  final tree = await fxEvents(Stream.value(0))
      .expandEach((n) => n >= 2 ? const Stream<int>.empty() : Stream.value(n + 1))
      .toList();
  print(tree); // [0, 1, 2]
  // Every value is emitted, THEN project is flattened — recursively,
  // breadth-first. The empty stream at 2 is what makes it terminate.
  // A project that never returns empty never ends. Not named expand:
  // the pull layer already uses that word for iterable flatMap.
}
