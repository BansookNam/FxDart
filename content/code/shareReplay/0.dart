import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // ReplayValue keeps a bounded buffer (size: 2 here; default is 1).
  // A late subscriber receives the retained values first, then live
  // updates — Rx's ReplaySubject.
  final recent = ReplayValue<int>(size: 2);
  recent.add(1);
  recent.add(2);

  final late = recent.live.toList();
  recent.add(3);
  await recent.close();

  print(await late); // [1, 2, 3]
}
