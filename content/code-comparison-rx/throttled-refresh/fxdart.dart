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
  final fired = await fxEvents(taps())
      .throttle(const Duration(milliseconds: 300))
      .toList();

  final lines = fired.map((tap) => 'refresh fired on tap $tap');
  lines.forEach(print);
  print('taps: 6, refreshes: ${fired.length}');
}
