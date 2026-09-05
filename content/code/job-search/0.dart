import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Simulated keystrokes: a quick burst, a pause, one more query.
Stream<String> keystrokes() {
  final c = StreamController<String>();
  const events = [(0, 'f'), (40, 'fx'), (80, 'fxd'), (800, 'fxdart')];
  for (final (ms, q) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(q));
  }
  Timer(const Duration(milliseconds: 1500), c.close);
  return c.stream;
}

const hits = {'fxd': 3, 'fxdart': 12};

Future<String> search(String q) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  return '${hits[q]} results for "$q"';
}

Future<void> main() async {
  final results = await fxEvents(keystrokes())
      .debounce(const Duration(milliseconds: 160))
      .asyncMap(search)
      .toList();

  results.forEach(print);
  // 3 results for "fxd"
  // 12 results for "fxdart"
}
