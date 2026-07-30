import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final samples = makeSamples();
  await bench(
    slug: 'stream-windowed-alerts',
    impl: 'native',
    n: n,
    run: () async {
      // A Stream can only be listened to once: create it fresh per run.
      final sensor = Stream<Reading>.fromIterable(samples);
      // Manual windowing: buffer 4 readings, flush, repeat.
      final windows = <(String, double, double)>[];
      var buf = <Reading>[];
      await for (final r in sensor) {
        buf.add(r);
        if (buf.length == 4) {
          final avg = buf.fold(0.0, (sum, r) => sum + r.c) / buf.length;
          final peak = buf.map((r) => r.c).reduce((a, b) => a > b ? a : b);
          windows.add(('${buf.first.second}s-${buf.last.second}s', avg, peak));
          buf = [];
        }
      }
      final alerts = windows.where((w) => w.$2 >= 75.0).length;
      final avgSum = windows.fold(0.0, (sum, w) => sum + w.$2);
      final first = windows.first;
      return '${windows.length}|alerts=$alerts'
          '|avgSum=${avgSum.toStringAsFixed(2)}'
          '|first=${first.$1},${first.$2.toStringAsFixed(2)},${first.$3.toStringAsFixed(1)}';
    },
  );
}
