import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A flaky sensor: two readings and one glitch in between.
  final sensor = StreamController<int>();
  final out = fxEvents(
    sensor.stream,
  ).attempt<String>((e, _) => 'E:$e').toList();

  sensor
    ..add(21)
    ..addError('glitch')
    ..add(22);
  await sensor.close();

  print(await out);
  // [Right(21), Left(E:glitch), Right(22)]
  // The chain kept running: a Dart stream error is an event, not the end
  // of the subscription. attempt turns it into a Left on the value
  // channel, so a StreamBuilder never sees an error state.
}
