import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Exercise: retryOn is retryWhen — on error the source is not
  // forwarded; the error is pushed into a notifier, and a next on that
  // notifier resubscribes. Here the notifier is the errors themselves,
  // so each failure retries immediately.
  var attempts = 0;
  final source = Stream<String>.multi((c) {
    attempts++;
    if (attempts == 1) {
      c
        ..addError(StateError('down'))
        ..close();
    } else {
      c
        ..add('connected')
        ..close();
    }
  });

  final out = await fxEvents(source)
      .retryOn((errors) => errors.map((_) {
            print('retrying');
          }).stream)
      .toList();

  print('attempts: $attempts'); // 2
  print(out); // [connected]
  // Notifier complete completes the result without forwarding the
  // error; notifier error is forwarded. Same re-listen caveat as
  // retryOnError: use Stream.multi, not a spent controller.
}
