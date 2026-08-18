import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final reqs = makeReqs();
  await bench(
    slug: 'latency-percentiles',
    impl: 'fxdart',
    n: n,
    run: () {
      final ok = fx(reqs).filter((r) => r.status == 200).toList();

      final rows = fx(fx(ok).groupBy((r) => r.endpoint).entries).map((e) {
        final sorted = fx(e.value).map((r) => r.ms).sort((a, b) => a.compareTo(b)).toList();
        int pct(int q) => nth(((sorted.length - 1) * q / 100).round(), sorted)!;
        return (e.key, pct(50), pct(95), sorted.length);
      }).toList();

      final lines = fx(rows)
          .sortBy((r) => -r.$3)
          .map(
            (r) =>
                '  ${r.$1.padRight(8)} p50 ${'${r.$2}'.padLeft(3)} ms  '
                'p95 ${'${r.$3}'.padLeft(3)} ms  (${r.$4} reqs)',
          )
          .toList();
      final worst = fx(rows).maxBy((r) => r.$3)!;

      return '${lines.length}|${lines.first}|${lines.last}|'
          'worst ${worst.$1} at ${worst.$3} ms';
    },
  );
}
