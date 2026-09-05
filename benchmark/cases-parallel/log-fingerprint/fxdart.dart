// 3 of 5 — the fxdart chain, still on one isolate.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final lines = makeLines();
  await bench(
    slug: 'log-fingerprint',
    impl: 'fxdart',
    n: n,
    run: () => checksum(fx(lines).map(fingerprint).toList()),
  );
}
