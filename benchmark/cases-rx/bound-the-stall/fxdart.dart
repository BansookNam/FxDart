import 'dart:async';

import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<double> readProbe(int i) async {
  await Future<void>.delayed(Duration.zero);
  return probeValues[i];
}

Future<void> main() async {
  await bench(
    slug: 'bound-the-stall',
    impl: 'fxdart',
    n: n,
    run: () async {
      final lines = <String>[];
      try {
        // Pull model: timeout bounds DEMAND-TO-ITEM time. The 5 s limit
        // can never fire at Duration.zero — the wrapper is what is timed.
        // Collect as we go, exactly like the example.
        await fx(probeIndices)
            .toAsync()
            .map(readProbe)
            .timeout(const Duration(seconds: 5))
            .map((v) => 'reading: ${v.toStringAsFixed(1)}')
            .each(lines.add);
      } on TimeoutException {
        lines.add('reading timed out'); // never taken at zero delay
      }
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
