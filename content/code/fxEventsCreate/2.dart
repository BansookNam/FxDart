import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Exercise: FxEvents.create hands you an EventEmitter — add events,
  // then close. Set emit.onCancel for teardown if the listener leaves
  // early; a throw from the init callback is forwarded and the stream
  // closes.
  final out = await FxEvents<int>.create((emit) {
    emit
      ..add(1)
      ..add(2)
      ..add(3)
      ..close();
  }).toList();

  print(out); // [1, 2, 3]
}
