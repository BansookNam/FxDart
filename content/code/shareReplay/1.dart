import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // CompletionValue remembers the last value and emits it only on
  // close — Rx's AsyncSubject. Subscribers while open receive
  // nothing; after close they get that last value, then done.
  final last = CompletionValue<int>();
  last.add(9);
  await last.close();

  print(await last.live.toList()); // [9]
}
