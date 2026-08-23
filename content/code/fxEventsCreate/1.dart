import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // defer runs its factory on listen, not construction — Rx's defer.
  // The chain itself is still single-subscription, like the rest of
  // FxEvents, so two listens are two defer(...) wrappers.
  var builds = 0;
  Stream<int> factory() {
    builds++;
    return Stream<int>.value(builds);
  }

  final deferred = FxEvents.defer(factory);
  print('before listen: $builds'); // 0
  print(await deferred.toList()); // [1]
  print(await FxEvents.defer(factory).toList()); // [2]
  print('factory ran $builds times'); // 2

  // fromFuture is also cold: the Future is not observed until a
  // listener arrives. An already-complete Future emits on listen.
  print(await FxEvents.fromFuture(Future.value(42)).toList()); // [42]
}
