import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // windowOn opens a window immediately, then rotates on each trigger
  // value: the current inner completes and the next one opens.
  final source = StreamController<int>(sync: true);
  final bounds = StreamController<void>(sync: true);
  final future = fxEvents(source.stream).windowOn(bounds.stream).toList();

  source.add(1);
  source.add(2);
  bounds.add(null); // rotate
  source.add(3);
  source.add(4);
  await source.close();

  final windows = await future;
  for (final w in windows) {
    print(await w.toList());
  }
  // [1, 2]
  // [3, 4]
  await bounds.close();
  // Boundary completion is ignored — the current window stays open
  // until the source completes. Cancelling the outer completes live
  // inners silently (RxJS 9), rather than erroring them.
}
