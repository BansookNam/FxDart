import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

String dd(int d) => '$d'.padLeft(3, '0');

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'sparse-timeseries',
    impl: 'native',
    n: n,
    run: () {
      final byDay = txns.groupListsBy((t) => t.day);
      final daily = [
        for (var d = 1; d <= totalDays; d++)
          (byDay[d] ?? const <Tx>[]).fold(0.0, (s, t) => s + t.amount),
      ];

      final weeks = <String>[];
      for (final (i, week) in daily.slices(7).indexed) {
        final start = i * 7 + 1;
        final cells = week.map((v) => v.toStringAsFixed(2)).join(' ');
        final total = week.fold(0.0, (s, v) => s + v);
        weeks.add('Day ${dd(start)}-${dd(start + 6)}: $cells'
            '  | week total ${total.toStringAsFixed(2)}');
      }

      return '${weeks.length}|${weeks.first}'
          '|${weeks[weeks.length ~/ 2]}|${weeks.last}';
    },
  );
}
