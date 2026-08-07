import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Emits each (offsetMs, value) pair at its offset, closing at [closeMs].
Stream<T> timed<T>(List<(int, T)> events, int closeMs) {
  final c = StreamController<T>();
  for (final (ms, v) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(v));
  }
  Timer(Duration(milliseconds: closeMs), c.close);
  return c.stream;
}

Future<void> main() async {
  // Exercise: a LiveValue fed straight from a stream. Unlike share() it
  // remembers, so a late subscriber is not left with nothing.
  final sensor = StreamController<int>();
  final temperature = LiveValue.seededFrom(20, sensor.stream);

  print(temperature.value); // 20 — the seed, before the source speaks

  sensor.add(23);
  await Future<void>.delayed(Duration.zero);
  print(temperature.value); // 23 — updated with nobody listening yet

  temperature.stream.listen((v) => print('late subscriber sees $v'));
  await Future<void>.delayed(Duration.zero); // replays 23 immediately

  sensor.add(24);
  await Future<void>.delayed(Duration.zero); // then the live update

  await temperature.close(); // cancels the source subscription too
  await sensor.close();
}
