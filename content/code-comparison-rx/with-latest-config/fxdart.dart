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

/// Tag both sources into one stream — the pairing withLatestFrom does for us.
Stream<(String, String)> tagged() {
  final c = StreamController<(String, String)>();
  var open = 2;
  void done() {
    if (--open == 0) c.close();
  }

  configs().listen((v) => c.add(('config', v)), onDone: done);
  requests().listen((r) => c.add(('request', r)), onDone: done);
  return c.stream;
}

Future<void> main() async {
  final stamped = await fxStream(tagged())
      .scan<(String, String?)>(
          (acc, ev) => ev.$1 == 'config' ? (ev.$2, null) : (acc.$1, ev.$2),
          ('', null))
      .filter((s) => s.$2 != null)
      .map((s) => '${s.$2} (config ${s.$1})')
      .toList();

  stamped.forEach(print);
}
