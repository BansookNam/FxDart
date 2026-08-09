import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final items = makeItems();
  await bench(
    slug: 'invoice-summary',
    impl: 'fxdart',
    n: n,
    run: () {
      final byCategory =
      fx(items).foldBy((l) => l.category, 0.0, (s, l) => s + l.qty * l.unitPrice);
      final lines = fx(byCategory.entries)
          .map((kv) => (kv.key, kv.value))
          .sortBy((row) => -row.$2)
          .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)}')
          .toList();
      final total = fx(items).sumBy((l) => l.qty * l.unitPrice);
      return '${lines.length}|${lines.first}|${lines.last}'
          '|total=${total.toStringAsFixed(2)}';
    },
  );
}
