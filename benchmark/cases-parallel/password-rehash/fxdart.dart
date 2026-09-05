// 3 of 5 — the fxdart chain, still on one isolate. Isolates the cost of the
// chain itself, so the parallel row below is not credited with it.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final creds = makeCredentials();
  await bench(
    slug: 'password-rehash',
    impl: 'fxdart',
    n: n,
    run: () => checksum(fx(creds).map(rehash).toList()),
  );
}
