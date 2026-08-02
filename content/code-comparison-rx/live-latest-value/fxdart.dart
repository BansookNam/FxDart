import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // No subject in a pull library: broadcast the raw updates and cache the
  // latest one by hand so a late reader has something to start from.
  final temps = StreamController<double>.broadcast();
  const updates = [(0, 18.2), (70, 18.6), (140, 19.1), (420, 19.5), (490, 20.0)];
  for (final (ms, t) in updates) {
    Timer(Duration(milliseconds: ms), () => temps.add(t));
  }
  Timer(const Duration(milliseconds: 630), temps.close);

  double? latest;
  final cache = temps.stream.listen((t) => latest = t);

  // The dashboard connects late — three updates have already gone by.
  await Future.delayed(const Duration(milliseconds: 280));
  final current = latest!; // the hand-cached "replay"
  final rest = await fxStream(temps.stream).toList();
  await cache.cancel();

  print('joined late, current: ${current.toStringAsFixed(1)}');
  for (final t in rest) {
    print('update: ${t.toStringAsFixed(1)}');
  }
}
