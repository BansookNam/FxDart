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
  await Future.delayed(const Duration(milliseconds: 20));
  return '${hits[q]} results for "$q"';
}

Future<void> main() async {
  // fxdart's debounce is a callback wrapper, not a stream operator — the
  // quiet queries have to be collected by hand, then searched as a pipeline.
  final quiet = <String>[];
  final debounced =
      debounce<String>(quiet.add, const Duration(milliseconds: 160));
  final done = Completer<void>();
  final sub = keystrokes().listen(debounced.call,
      // The trailing debounce window may still be pending at close.
      onDone: () => Timer(const Duration(milliseconds: 200), done.complete));
  await done.future;
  await sub.cancel();

  final results = await fx(quiet).toAsync().map(search).toList();

  results.forEach(print);
}
