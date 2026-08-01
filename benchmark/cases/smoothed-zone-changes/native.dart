import '../../harness.dart';
import 'data.dart';

String zone(double t) => t < 20 ? 'cool' : (t < 25 ? 'ok' : 'hot');

Future<void> main() async {
  final temps = makeTemps();
  await bench(
    slug: 'smoothed-zone-changes',
    impl: 'native',
    n: n,
    run: () {
      final smoothed = <double>[];
      for (var i = 0; i + 3 <= temps.length; i++) {
        var sum = 0.0;
        for (var j = i; j < i + 3; j++) {
          sum += temps[j];
        }
        smoothed.add(sum / 3);
      }
      final runStarts = <double>[];
      for (final s in smoothed) {
        if (runStarts.isEmpty || zone(s) != zone(runStarts.last)) {
          runStarts.add(s);
        }
      }
      final lines = <String>[];
      for (var i = 1; i < runStarts.length; i++) {
        final from = runStarts[i - 1];
        final to = runStarts[i];
        lines.add('${zone(from)} → ${zone(to)}'
            ' (avg ${from.toStringAsFixed(1)} → ${to.toStringAsFixed(1)})');
      }
      if (lines.isEmpty) {
        lines.add('stable — no zone changes');
      }
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
