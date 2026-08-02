import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Simulated deploys: the config version bumps between requests.
Stream<String> configs() {
  final c = StreamController<String>();
  const events = [(0, 'v1'), (200, 'v2'), (500, 'v3')];
  for (final (ms, v) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(v));
  }
  Timer(const Duration(milliseconds: 700), c.close);
  return c.stream;
}

/// Simulated API calls, fired at fixed offsets.
Stream<String> requests() {
  final c = StreamController<String>();
  const events = [
    (80, 'GET /orders'),
    (300, 'GET /stock'),
    (400, 'GET /prices'),
    (600, 'GET /refunds'),
  ];
  for (final (ms, r) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(r));
  }
  Timer(const Duration(milliseconds: 700), c.close);
  return c.stream;
}

Future<void> main() async {
  final stamped = await fxEvents(requests())
      .withLatestFrom(configs(), (req, cfg) => '$req (config $cfg)')
      .toList();

  stamped.forEach(print);
}
