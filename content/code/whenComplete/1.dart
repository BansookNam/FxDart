import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // endWith appends a value when the source closes. ifEmpty emits a
  // fallback only when the source closed without emitting — otherwise
  // the source is mirrored as-is.
  print(
    await fxEvents(Stream.fromIterable([1, 2])).endWith(0).toList(),
  ); // [1, 2, 0]
  print(await FxEvents<int>.empty().ifEmpty(() => -1).toList()); // [-1]
  print(
    await fxEvents(Stream.fromIterable([1, 2])).ifEmpty(() => -1).toList(),
  ); // [1, 2]
}
