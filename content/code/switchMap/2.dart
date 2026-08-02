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
  // Autocomplete: every keystroke kicks off a ~100ms suggestion fetch.
  final keys = timed([(0, 's'), (40, 'sw'), (80, 'swi')], 300);

  Stream<String> suggest(String q) => timed([(100, '$q…suggestions')], 130);

  // TODO: only the NEWEST query's suggestions should reach the screen —
  // replace asyncExpand (which dutifully shows every stale result) with
  //   fxEvents(keys).switchMap(suggest).toList()
  final out = await keys.asyncExpand(suggest).toList();

  print(out);
  // currently every query's suggestions — want [swi…suggestions]:
  // 's' and 'sw' are superseded before their fetch comes back.
}
