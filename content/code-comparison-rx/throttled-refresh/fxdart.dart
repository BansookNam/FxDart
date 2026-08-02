import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Simulated refresh-button taps: two quick bursts, then one late tap.
Stream<int> taps() {
  final c = StreamController<int>();
  const offsets = [0, 50, 100, 400, 450, 800];
  for (final (i, ms) in offsets.indexed) {
    Timer(Duration(milliseconds: ms), () => c.add(i));
  }
  Timer(const Duration(milliseconds: 1000), c.close);
  return c.stream;
}

Future<void> main() async {
  // fxdart's throttle is a callback wrapper, not a stream operator — it is
  // wired to the tap stream by hand, collecting the taps that get through.
  final fired = <int>[];
  final throttled = throttle<int>(fired.add, const Duration(milliseconds: 300),
      trailing: false);
  final done = Completer<void>();
  final sub = taps().listen(throttled.call, onDone: done.complete);
  await done.future;
  await sub.cancel();

  final lines = fx(fired).map((tap) => 'refresh fired on tap $tap').toList();
  lines.forEach(print);
  print('taps: 6, refreshes: ${fired.length}');
}
