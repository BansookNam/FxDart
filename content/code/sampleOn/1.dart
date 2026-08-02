import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // An ENDLESS trigger: a tick every 40ms, forever.
  final ticks = Stream<void>.periodic(const Duration(milliseconds: 40));

  final source = StreamController<int>();
  Timer(const Duration(milliseconds: 10), () => source.add(7));
  Timer(const Duration(milliseconds: 200), source.close);

  final out = await fxEvents(source.stream).sampleOn(ticks).toList();

  print(out); // [7]
  // Several ticks fire before the source closes, but only the FIRST one
  // after the 7 arrived emits — a trigger with nothing new is silent.
  // And when the source closes, the chain closes with it: the endless
  // tick stream is cancelled, not awaited.
}
