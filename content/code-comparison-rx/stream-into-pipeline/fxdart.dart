import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// A live log feed: seven lines on a fixed schedule, then it closes.
Stream<String> logFeed() {
  final c = StreamController<String>();
  const events = [
    (0, 'info: service up'),
    (60, 'warn: disk 81% full'),
    (120, 'info: heartbeat'),
    (180, 'warn: latency 900ms'),
    (240, 'info: heartbeat'),
    (300, 'warn: retry queue at 12'),
    (360, 'info: sync done'),
  ];
  for (final (ms, line) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(line));
  }
  Timer(const Duration(milliseconds: 420), c.close);
  return c.stream;
}

Future<void> main() async {
  // Bridge the push source once, then it is a typed pull pipeline.
  final warnings = await fxStream(logFeed())
      .filter((line) => line.startsWith('warn'))
      .map((line) => line.toUpperCase())
      .toList();

  warnings.forEach(print);
  print('warnings: ${warnings.length}');
}
