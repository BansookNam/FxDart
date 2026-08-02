import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

/// The log feed — the example's timed controller becomes an immediate
/// stream over the shared dataset (identical on both sides).
Stream<String> logFeed() => Stream.fromIterable(lines);

Future<void> main() async {
  await bench(
    slug: 'stream-into-pipeline',
    impl: 'fxdart',
    n: n,
    run: () async {
      // Bridge the push source once, then it is a typed pull pipeline.
      final warnings = await fxStream(logFeed())
          .filter((line) => line.startsWith('warn'))
          .map((line) => line.toUpperCase())
          .toList();
      return '${warnings.length}|${warnings.last}';
    },
  );
}
