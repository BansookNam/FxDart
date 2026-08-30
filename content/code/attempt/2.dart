import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Exercise: attempt AFTER retry converts a retried failure; attempt
  // BEFORE retry leaves nothing on the error channel to retry.
  var listens = 0;
  Stream<int> flaky() {
    listens++;
    return listens < 3 ? Stream<int>.error('boom $listens') : Stream.value(7);
  }

  print(
    await FxEvents.retry(flaky, 5).attempt<String>((e, _) => 'E:$e').toList(),
  );
  // [Right(7)] — three listens, then a success converted to Right.

  listens = 0;
  print(
    await fxEvents(
      flaky(),
    ).attempt<String>((e, _) => 'E:$e').retryOnError(count: 5).toList(),
  );
  // [Left(E:boom 1)] — one listen. The error is already a value.
}
