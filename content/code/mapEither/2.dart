import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Exercise: a *thrown* exception stays on the error channel — that is
  // the either builder's contract. attempt is the single place a throw
  // becomes a value. The chain still continues past the throw.
  final signals = <String>[];
  final done = Completer<void>();
  fxEvents(Stream.fromIterable([1, 2]))
      .mapEither<String, int>((r, v) {
        if (v == 1) throw StateError('boom');
        return v;
      })
      .listen(
        (e) => signals.add('$e'),
        onError: (Object e) => signals.add('error ${e.runtimeType}'),
        onDone: done.complete,
      );
  await done.future;
  print(signals); // [error StateError, Right(2)]
}
