import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // raiseLefts is the other direction: unwrap each Right, put each Left
  // back on the error channel — for a boundary that hands the stream to
  // Stream-based code expecting Dart errors.
  final signals = <String>[];
  final done = Completer<void>();
  fxEvents(
    Stream.fromIterable(<Either<String, int>>[
      const Right(1),
      const Left('boom'),
      const Right(2),
    ]),
  ).raiseLefts().listen(
    (v) => signals.add('data $v'),
    onError: (Object e) => signals.add('error $e'),
    onDone: done.complete,
  );
  await done.future;
  print(signals); // [data 1, error boom, data 2]

  // An attempt / raiseLefts round trip keeps the failure *value* and
  // drops the original stack trace — Left does not carry one.
  final src = StreamController<int>();
  final roundTrip = <String>[];
  final closed = Completer<void>();
  fxEvents(src.stream)
      .attempt<String>((e, _) => 'E:$e')
      .raiseLefts()
      .listen(
        (v) => roundTrip.add('data $v'),
        onError: (Object e) => roundTrip.add('error $e'),
        onDone: closed.complete,
      );
  src
    ..add(7)
    ..addError('glitch');
  await src.close();
  await closed.future;
  print(roundTrip); // [data 7, error E:glitch]
}
