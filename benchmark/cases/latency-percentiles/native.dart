import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final reqs = makeReqs();
  await bench(
    slug: 'latency-percentiles',
    impl: 'native',
    n: n,
    run: () {
      final ok = reqs.where((r) => r.status == 200).toList();

      final rows = <(String, int, int, int)>[];
      for (final e in ok.groupListsBy((r) => r.endpoint).entries) {
        final sorted = e.value.map((r) => r.ms).toList()..sort();
        int pct(int q) => sorted[((sorted.length - 1) * q / 100).round()];
        rows.add((e.key, pct(50), pct(95), sorted.length));
      }

      final lines = rows
          .sortedBy<num>((r) => -r.$3)
          .map(
            (r) =>
                '  ${r.$1.padRight(8)} p50 ${'${r.$2}'.padLeft(3)} ms  '
                'p95 ${'${r.$3}'.padLeft(3)} ms  (${r.$4} reqs)',
          )
          .toList();
      final worst = rows.reduce((a, b) => a.$3 >= b.$3 ? a : b);

      return '${lines.length}|${lines.first}|${lines.last}|'
          'worst ${worst.$1} at ${worst.$3} ms';
    },
  );
}
