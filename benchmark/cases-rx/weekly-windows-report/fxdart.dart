import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final dailyCents = makeDailyCents();
  await bench(
    slug: 'weekly-windows-report',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(dailyCents)
          .chunk(7)
          .zipWithIndex()
          .map((w) => 'week ${w.$1 + 1}: '
              '\$${fx(w.$2).sumBy((c) => c / 100).toStringAsFixed(2)}')
          .toList();

      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
