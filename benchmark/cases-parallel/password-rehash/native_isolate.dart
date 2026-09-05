// 2 of 5 — hand-rolled isolates: slice the list, one Isolate.run per slice,
// wait for all, concatenate. This is what you write when you reach for
// dart:isolate directly, and it is what `parallel` has to beat.
import 'dart:isolate';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final creds = makeCredentials();
  await bench(
    slug: 'password-rehash',
    impl: 'native-isolate',
    n: n,
    run: () async {
      final slices = sliceEvenly(creds, benchWorkers);
      final parts = await Future.wait([
        for (final s in slices) Isolate.run(() => rehashAll(s)),
      ]);
      return checksum([for (final p in parts) ...p]);
    },
  );
}
