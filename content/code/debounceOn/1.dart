import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // delayOn holds every value until ITS selector fires once. Here the
  // selector is a shared notifier, so nothing moves until we say go.
  final source = StreamController<String>();
  final release = StreamController<void>.broadcast();
  final seen = <String>[];
  final done = Completer<void>();

  fxEvents(source.stream)
      .delayOn((_) => release.stream)
      .listen(seen.add, onDone: done.complete);

  source
    ..add('held a')
    ..add('held b');
  await Future<void>.delayed(const Duration(milliseconds: 20));
  print(seen); // [] — both values are waiting on the notifier

  release.add(null);
  await Future<void>.delayed(const Duration(milliseconds: 20));
  print(seen); // [held a, held b]

  await source.close();
  await done.future;
  await release.close();
  // Inners run independently, so if two selectors fired out of order
  // the values would too — matching Rx's delayWhen. Inner completion
  // without a next drops that value; the close waits for outstanding
  // inners.
}
