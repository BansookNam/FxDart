import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Simulated gauge: pressure readings 1..8, one every 50 ms.
Stream<int> gauge() {
  final c = StreamController<int>();
  for (var i = 1; i <= 8; i++) {
    Timer(Duration(milliseconds: 50 * i), () => c.add(i));
  }
  Timer(const Duration(milliseconds: 500), c.close);
  return c.stream;
}

/// The dashboard polls three times, each tick landing between readings.
Stream<void> polls() {
  final c = StreamController<void>();
  for (final ms in const [125, 275, 425]) {
    Timer(Duration(milliseconds: ms), () => c.add(null));
  }
  Timer(const Duration(milliseconds: 550), c.close);
  return c.stream;
}

Future<void> main() async {
  // The gauge's latest reading is tracked by hand in a variable; the poll
  // ticks are pulled through the bridge and each pull snapshots it.
  var latest = 0;
  final sub = gauge().listen((v) => latest = v);

  final sampled = await fxStream(polls()).map((_) => latest).toList();
  await sub.cancel();

  for (final (i, value) in sampled.indexed) {
    print('poll ${i + 1}: reading $value');
  }
}
