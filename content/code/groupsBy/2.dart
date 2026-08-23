import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Exercise: group these SKUs by department prefix and print each
  // group's items. The key is everything before the dash.
  final skus = [
    'hw-mouse',
    'hw-keyboard',
    'sw-editor',
    'hw-monitor',
    'sw-cli',
  ];

  final groups = await fxEvents(Stream.fromIterable(skus))
      .groupsBy((s) => s.split('-').first)
      .toList();

  print([for (final g in groups) g.key]); // [hw, sw]
  for (final g in groups) {
    print('${g.key}: ${await g.events.toList()}');
  }
  // hw: [hw-mouse, hw-keyboard, hw-monitor]
  // sw: [sw-editor, sw-cli]
}
