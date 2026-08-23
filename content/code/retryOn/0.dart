import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // retryOnError re-listens the same stream, so the source must itself
  // allow a second listen — Stream.multi (used here), Stream.fromIterable,
  // or a broadcast. A spent StreamController will error on the retry;
  // rebuild those with FxEvents.retry(factory) instead.
  var attempts = 0;
  final source = Stream<int>.multi((c) {
    attempts++;
    print('attempt $attempts');
    if (attempts < 2) {
      c
        ..addError(StateError('flaky'))
        ..close();
    } else {
      c
        ..add(42)
        ..close();
    }
  });

  final out = await fxEvents(source)
      .retryOnError(
        count: 2,
        delay: (n) => Duration(milliseconds: 40 * n),
      )
      .toList();

  print(out); // [42]
  // count is retries, not attempts: count: 2 allows three tries. delay
  // receives the 1-based retry number, so backoff is one line.
}
