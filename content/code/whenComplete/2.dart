import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Exercise: whenComplete (Rx finalize) runs exactly once — on done,
  // on error, or on cancel. Even if the callback throws, the chain
  // still tears down.
  var n = 0;
  print(
    await fxEvents(Stream.fromIterable([1, 2])).whenComplete(() => n++).toList(),
  ); // [1, 2]
  print('on done: $n'); // 1

  final c = StreamController<int>();
  final sub = fxEvents(c.stream).whenComplete(() => n++).listen((_) {});
  await sub.cancel();
  print('on cancel: $n'); // 2
  await c.close();
}
