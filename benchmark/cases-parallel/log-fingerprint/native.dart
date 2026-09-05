// 1 of 5 — a plain loop. One isolate, no chain. The baseline.
import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final lines = makeLines();
  await bench(
    slug: 'log-fingerprint',
    impl: 'native',
    n: n,
    run: () {
      final out = <Fingerprint>[];
      for (final l in lines) {
        out.add(fingerprint(l));
      }
      return checksum(out);
    },
  );
}
