import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final items = makeItems();
  await bench(
    slug: 'restock-plan',
    impl: 'fxdart',
    n: n,
    run: () {
      final needed = fx(items)
          .filter((i) => i.stock < i.minStock)
          .sortBy((i) => i.stock - i.minStock) // biggest deficit first
          .toList();

      final running = fx(needed)
          .scan((acc, i) => acc + i.reorderQty * i.unitCost, 0.0)
          .drop(1); // scan emits the seed first

      final plan = fx(
        needed,
      ).zip(running).takeWhile((p) => p.$2 <= budget).toList();
      final lines = fx(plan)
          .map(
            (p) =>
                '  ${p.$1.name.padRight(15)} '
                'x${'${p.$1.reorderQty}'.padLeft(3)}  '
                '${money(p.$1.reorderQty * p.$1.unitCost).padRight(8)} '
                'running ${money(p.$2)}',
          )
          .toList();
      final spent = fx(plan).sumBy((p) => p.$1.reorderQty * p.$1.unitCost);

      return '${lines.length}/${needed.length}|${lines.first}|'
          'total ${money(spent)}, ${money(budget - spent)} left';
    },
  );
}
