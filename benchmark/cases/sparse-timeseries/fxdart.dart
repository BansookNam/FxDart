import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String dd(int d) => '$d'.padLeft(3, '0');

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'sparse-timeseries',
    impl: 'fxdart',
    n: n,
    run: () {
      final byDay = fx(txns).groupBy((t) => t.day);
      final daily = fx(range(1, totalDays + 1))
          .map((d) => fx(byDay[d] ?? const <Tx>[]).sumBy((t) => t.amount))
          .toList();

      final weeks = fx(daily).chunk(7).zipWithIndex().map((w) {
        final start = w.$1 * 7 + 1;
        final cells = join(' ', fx(w.$2).map((v) => v.toStringAsFixed(2)));
        final total = fx(w.$2).sumBy((v) => v);
        return 'Day ${dd(start)}-${dd(start + 6)}: $cells'
            '  | week total ${total.toStringAsFixed(2)}';
      }).toList();

      return '${weeks.length}|${weeks.first}'
          '|${weeks[weeks.length ~/ 2]}|${weeks.last}';
    },
  );
}
