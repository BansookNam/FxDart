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
  // A search box: the user refines the query while the first search is
  // still in flight (each search takes ~150ms).
  final queries = timed([(0, 'da'), (60, 'dart')], 400);
  final started = <String>[];

  Stream<String> search(String q) {
    started.add(q);
    return timed([(150, 'results for "$q"')], 200);
  }

  final out = await fxEvents(queries).switchMap(search).toList();

  print('started:   $started'); // [da, dart]
  print('delivered: $out'); // [results for "dart"]
  // Both searches started — but 'dart' arrived while 'da' was in flight,
  // so the older inner stream was CANCELLED mid-request. No stale results
  // can ever overwrite newer ones.
}
