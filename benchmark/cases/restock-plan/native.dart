import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final items = makeItems();
  await bench(
    slug: 'restock-plan',
    impl: 'native',
    n: n,
    run: () {
      final needed = items
          .where((i) => i.stock < i.minStock)
          .sortedBy<num>((i) => i.stock - i.minStock); // biggest deficit first

      final lines = <String>[];
      var running = 0.0;
      for (final i in needed) {
        final cost = i.reorderQty * i.unitCost;
        if (running + cost > budget) break;
        running += cost;
        lines.add(
          '  ${i.name.padRight(15)} '
          'x${'${i.reorderQty}'.padLeft(3)}  '
          '${money(cost).padRight(8)} '
          'running ${money(running)}',
        );
      }

      return '${lines.length}/${needed.length}|${lines.first}|'
          'total ${money(running)}, ${money(budget - running)} left';
    },
  );
}
