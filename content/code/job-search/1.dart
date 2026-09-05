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
  // The user refines the query while the first search is still in flight.
  final queries = timed([(0, 'da'), (60, 'dart')], 400);
  final started = <String>[];

  Stream<String> search(String q) {
    started.add(q);
    return timed([(150, 'hits for "$q"')], 200);
  }

  final out = await fxEvents(queries)
      .switchMap(search)
      .mapEither<String, String>(
        (r, hit) => r.ensureNotNull(
          hit.startsWith('hits') ? hit : null,
          () => 'empty: $hit',
        ),
      )
      .toList();

  print('started:   $started'); // [da, dart]
  print('delivered: $out'); // [Right(hits for "dart")]
}
