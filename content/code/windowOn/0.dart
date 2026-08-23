import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // windowCount emits nested FxEvents, not lists: each inner is live,
  // so a subscriber can see values before the window closes. Inners
  // buffer until listened, so collecting them after the outer is fine.
  final windows = await fxEvents(Stream.fromIterable([1, 2, 3, 4]))
      .windowCount(2)
      .toList();

  for (final w in windows) {
    final list = await w.toList();
    if (list.isNotEmpty) print(list);
  }
  // [1, 2]
  // [3, 4]
  //
  // A new inner opens as soon as the previous one fills, so a trailing
  // empty window can appear — skipped here. chunk(2) would emit the
  // lists directly and skip empties.
}
