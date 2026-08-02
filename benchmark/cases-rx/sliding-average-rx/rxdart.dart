import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final temps = makeTemps();
  await bench(
    slug: 'sliding-average-rx',
    impl: 'rxdart',
    n: n,
    run: () async {
      // The sliding window is spelled bufferCount(3, 1): buffers of 3,
      // starting a new buffer every 1 event. It also emits the ramp-down
      // partials — filter by length to keep full windows.
      final report = await Stream.fromIterable(temps)
          .bufferCount(3, 1)
          .where((w) => w.length == 3)
          .map((w) {
            final avg = w.reduce((a, b) => a + b) / w.length;
            final values = w.map((t) => t.toStringAsFixed(1)).join(' ');
            return '$values -> avg ${avg.toStringAsFixed(1)}';
          })
          .toList();
      return '${report.length}|${report.first}|${report.last}';
    },
  );
}
