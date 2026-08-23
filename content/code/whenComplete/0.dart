import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // peek runs a side effect and passes the event through unchanged —
  // Rx's tap / doOn*, staying on the FxEvents chain.
  final seen = <int>[];
  print(
    await fxEvents(Stream.fromIterable([10, 20, 30])).peek(seen.add).toList(),
  ); // [10, 20, 30]
  print(seen); // [10, 20, 30]
}
