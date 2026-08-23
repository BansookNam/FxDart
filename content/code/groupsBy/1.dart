import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // lastFor closes a group: the first event (or completion) of
  // lastFor(key) completes that inner. A later value with the same
  // key opens a new one.
  final source = StreamController<String>();
  final lasts = <String, StreamController<void>>{};
  final future = fxEvents(source.stream)
      .groupsBy(
        (s) => s[0],
        lastFor: (key) => (lasts[key] = StreamController<void>()).stream,
      )
      .toList();

  source.add('a1');
  source.add('a2');
  await Future<void>.delayed(Duration.zero);
  lasts['a']!.add(null); // close group a
  await Future<void>.delayed(Duration.zero);
  source.add('a3'); // reopens a
  source.add('b1');
  await source.close();

  final groups = await future;
  print([for (final g in groups) g.key]); // [a, a, b]
  for (final g in groups) {
    print('${g.key}: ${await g.events.toList()}');
  }
  // a: [a1, a2]
  // a: [a3]
  // b: [b1]
  //
  // Cancelling the outer completes live groups silently, the same
  // RxJS 9 rule window* follows.
}
