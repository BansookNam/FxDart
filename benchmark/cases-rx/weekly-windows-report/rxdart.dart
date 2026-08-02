import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final dailyCents = makeDailyCents();
  await bench(
    slug: 'weekly-windows-report',
    impl: 'rxdart',
    n: n,
    run: () async {
      final lines = await Stream.fromIterable(dailyCents)
          .bufferCount(7)
          // No indexed operator — scan is drafted as the week counter.
          .scan<(int, List<int>)>((acc, week, _) => (acc.$1 + 1, week), (0, []))
          .map((w) => 'week ${w.$1}: '
              '\$${w.$2.fold<double>(0, (s, c) => s + c / 100).toStringAsFixed(2)}')
          .toList();

      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
