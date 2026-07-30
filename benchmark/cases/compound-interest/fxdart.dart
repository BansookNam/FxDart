import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'compound-interest',
    impl: 'fxdart',
    n: n,
    run: () {
      final table = fx(range(1, n + 1))
          .scan((row, year) => (year, row.$2 * (1 + rate)), (0, principal))
          .map((row) => 'year ${row.$1}: \$${row.$2.toStringAsFixed(2)}')
          .toList();
      return '${table.length}|${table.first}|${table.last}';
    },
  );
}
