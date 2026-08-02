import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<double> readProbe(int i) async {
  await Future<void>.delayed(Duration.zero);
  return probeValues[i];
}

Future<void> main() async {
  await bench(
    slug: 'bound-the-stall',
    impl: 'rxdart',
    n: n,
    run: () async {
      // The budget is per read, so bound the Future itself. The 5 s limit
      // can never fire at Duration.zero — the wrapper is what is timed.
      final lines = await Stream.fromIterable(probeIndices)
          .asyncMap((i) => readProbe(i).timeout(const Duration(seconds: 5)))
          .map((v) => 'reading: ${v.toStringAsFixed(1)}')
          // Replace a timeout error with a report line…
          .onErrorReturnWith((_, _) => 'reading timed out')
          // …and stop there (never taken at zero delay).
          .takeWhileInclusive((line) => line != 'reading timed out')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
