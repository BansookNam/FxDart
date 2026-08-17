import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final temps = makeTemps();
  await bench(
    slug: 'sliding-average-rx',
    impl: 'fxdart',
    n: n,
    run: () {
      final report = fx(temps).windowed(3).map((w) {
        final values = w.map((t) => t.toStringAsFixed(1)).join(' ');
        return '$values -> avg ${average(w).toStringAsFixed(1)}';
      }).toList();
      return '${report.length}|${report.first}|${report.last}';
    },
  );
}
