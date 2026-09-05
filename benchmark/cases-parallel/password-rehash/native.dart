// 1 of 5 — a plain loop. One isolate, no chain. The baseline.
import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final creds = makeCredentials();
  await bench(
    slug: 'password-rehash',
    impl: 'native',
    n: n,
    run: () {
      final out = <Derived>[];
      for (final c in creds) {
        out.add(rehash(c));
      }
      return checksum(out);
    },
  );
}
