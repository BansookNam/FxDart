import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final samples = makeSamples();
  await bench(
    slug: 'stream-windowed-alerts',
    impl: 'fxdart',
    n: n,
    run: () async {
      // A Stream can only be listened to once: create it fresh per run.
      final windows = await fxStream(Stream<Reading>.fromIterable(samples))
          .chunk(4)
          .map((w) => (
                '${w.first.second}s-${w.last.second}s',
                fx(w).averageBy((r) => r.c),
                fx(w).maxBy((r) => r.c)!.c,
              ))
          .toList();
      final alerts = fx(windows).filter((w) => w.$2 >= 75.0).size();
      final avgSum = fx(windows).sumBy((w) => w.$2);
      final first = windows.first;
      return '${windows.length}|alerts=$alerts'
          '|avgSum=${avgSum.toStringAsFixed(2)}'
          '|first=${first.$1},${first.$2.toStringAsFixed(2)},${first.$3.toStringAsFixed(1)}';
    },
  );
}
