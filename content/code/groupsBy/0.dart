import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // The first value of each key emits a GroupedEvents; later values
  // with that key go to its inner. Inners buffer until listened, so
  // collecting them after the outer is fine.
  final groups = await fxEvents(Stream.fromIterable(['a1', 'b1', 'a2']))
      .groupsBy((s) => s[0])
      .toList();

  print([for (final g in groups) g.key]); // [a, b]
  for (final g in groups) {
    print('${g.key}: ${await g.events.toList()}');
  }
  // a: [a1, a2]
  // b: [b1]
  //
  // Groups appear in first-seen key order. Unlike pull groupBy this is
  // not a terminal Map — each group is live {key, events}.
}
