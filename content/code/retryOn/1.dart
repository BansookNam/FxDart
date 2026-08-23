import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // repeat re-subscribes on completion (not error). count: 1 is one
  // extra run, so a short stream plays twice.
  final source = Stream<int>.multi((c) {
    c
      ..add(1)
      ..add(2)
      ..close();
  });

  final out = await fxEvents(source)
      .repeat(count: 1)
      .whenComplete(() => print('cleaned up'))
      .toList();

  print(out); // [1, 2, 1, 2]
  // whenComplete is Rx finalize: the callback runs exactly once on
  // done, error, or cancel — here after the second run closes. Errors
  // on repeat forward and stop; they do not trigger another run.
  // repeatOn is the notifier form: resubscribe when that stream fires.
}
