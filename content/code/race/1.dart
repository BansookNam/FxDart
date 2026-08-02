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
  // An ERROR can win the race too: the first event decides, whether it
  // is a value or a failure. A fast broken endpoint beats a slow good one.
  final failing = timed([(30, 'x')], 60)
      .asyncMap((_) => Future<String>.error(StateError('mirror down')));
  final slow = timed([(200, 'slow but fine')], 240);
  try {
    await FxEvents.race([failing, slow]).toList();
  } on StateError catch (e) {
    print('race lost to an error: ${e.message}');
  }

  // Candidates that close WITHOUT emitting simply drop out; when all of
  // them do (or the field is empty), the race closes empty.
  print(await FxEvents.race<int>([timed([], 30), timed([], 50)]).toList());
  // []
  print(await FxEvents.race<int>(const []).toList());
  // []
}
