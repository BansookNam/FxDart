import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<List<String>> drain(FxEvents<Object?> src) {
  final out = <String>[];
  final done = Completer<void>();
  src.listen(
    (v) => out.add('data $v'),
    onError: (Object e) => out.add('error $e'),
    onDone: done.complete,
  );
  return done.future.then((_) => out);
}

Future<void> main() async {
  // Exercise: an error *event* is not an Either, so separated fans it
  // out to every side currently listening. attempt upstream counts the
  // failure once, as a Left on the failures half.

  final raw = StreamController<Either<String, int>>();
  final (rawFail, rawOk) = fxEvents(raw.stream).separated();
  final rawFailD = drain(rawFail);
  final rawOkD = drain(rawOk);
  raw
    ..add(const Right(1))
    ..addError('boom')
    ..add(const Right(2));
  await raw.close();
  print('without attempt');
  print(await rawFailD); // [error boom]
  print(await rawOkD); // [data 1, error boom, data 2]

  final src = StreamController<int>();
  final (failures, successes) = fxEvents(
    src.stream,
  ).attempt<String>((e, _) => 'E:$e').separated();
  final failD = drain(failures);
  final okD = drain(successes);
  src
    ..add(1)
    ..addError('boom')
    ..add(2);
  await src.close();
  print('with attempt');
  print(await failD); // [data E:boom]
  print(await okD); // [data 1, data 2]
}
