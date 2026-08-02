import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A LiveValue IS the "current value": every new listener first
  // gets the latest update, then everything after it.
  final temps = LiveValue<double>();
  const updates = [(0, 18.2), (70, 18.6), (140, 19.1), (420, 19.5), (490, 20.0)];
  for (final (ms, t) in updates) {
    Timer(Duration(milliseconds: ms), () => temps.add(t));
  }
  Timer(const Duration(milliseconds: 630), temps.close);

  // The dashboard connects late — three updates have already gone by.
  await Future.delayed(const Duration(milliseconds: 280));
  final seen = await temps.live.toList();

  print('joined late, current: ${seen.first.toStringAsFixed(1)}');
  for (final t in seen.skip(1)) {
    print('update: ${t.toStringAsFixed(1)}');
  }
}
