// 2 of 5 — hand-rolled isolates: one Isolate.run per slice.
//
// Note what this variant does *not* pay: the slices are sent once, so it is
// already the batched shape. That is exactly why plain `parallel` loses here
// and `parallel(chunk:)` does not — the comparison is only fair once both
// sides send the same number of messages.
import 'dart:isolate';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final lines = makeLines();
  await bench(
    slug: 'log-fingerprint',
    impl: 'native-isolate',
    n: n,
    run: () async {
      final slices = sliceEvenly(lines, benchWorkers);
      final parts = await Future.wait([
        for (final s in slices) Isolate.run(() => fingerprintAll(s)),
      ]);
      return checksum([for (final p in parts) ...p]);
    },
  );
}
