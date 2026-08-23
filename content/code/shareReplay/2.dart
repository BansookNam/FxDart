import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Exercise: shareReplay multicasts through a ReplayValue. Two
  // listeners share one run of the source; late listeners get the
  // retained history, then follow.
  final shared = fxEvents(Stream.fromIterable([1, 2, 3])).shareReplay();

  final a = shared.toList();
  final b = shared.toList();

  print(await a); // [1, 2, 3]
  print(await b); // [1, 2, 3]
}
