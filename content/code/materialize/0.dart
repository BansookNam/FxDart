import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Data becomes Next; close becomes Done — terminals travel as values.
  print(await fxEvents(Stream.fromIterable([1, 2])).materialize().toList());
  // [Next(1), Next(2), Done()]

  // An error becomes Err, then the chain completes — it does not error.
  final src = StreamController<int>();
  final events = fxEvents(src.stream).materialize().toList();
  src
    ..add(1)
    ..addError(StateError('boom'));
  await src.close();
  print(await events);
  // [Next(1), Err(Bad state: boom)]

  // dematerialize is the inverse: Next → value, Done → close.
  print(
    await fxEvents(
      Stream.fromIterable([1, 2, 3]),
    ).materialize().dematerialize().toList(),
  );
  // [1, 2, 3]
}
