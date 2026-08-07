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
  // A live feed that dies mid-session; fall back to the cache.
  final network = StreamController<String>();
  final out = fxEvents(network.stream)
      .onErrorResume((error, _) => Stream.fromIterable(['cached A', 'cached B']))
      .toList();

  network
    ..add('live 1')
    ..addError(StateError('connection lost'))
    ..add('live 2'); // never arrives — the source was abandoned
  await Future<void>.delayed(const Duration(milliseconds: 20));
  await network.close();

  print(await out); // [live 1, cached A, cached B]
  // Unlike onErrorReturn this is a ONE-SHOT switch: the source is
  // cancelled at the first error and the fallback takes over entirely.
}
