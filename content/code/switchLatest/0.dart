import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A stream of streams: each event already IS an inner stream.
  final outer = Stream.fromIterable([
    Stream.fromIterable([1]),
    Stream.fromIterable([2, 3]),
  ]);

  final out = await fxEvents(outer).switchLatest().toList();
  print(out); // [1, 2, 3]
  // Newest inner is mirrored — identity switchMap((s) => s).
  // Both inners completed as they arrived (sync), so nothing was
  // cancelled — overlapping inners are cancelled mid-flight.
}
