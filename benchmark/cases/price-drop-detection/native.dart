import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final june = makeJune();
  final july = makeJuly();
  await bench(
    slug: 'price-drop-detection',
    impl: 'native',
    n: n,
    run: () {
      final old = {for (final i in june) i.sku: i};
      final drops = july
          .where((i) => old.containsKey(i.sku) && i.price < old[i.sku]!.price)
          .map((i) => (i, old[i.sku]!.price - i.price))
          .sortedBy<num>((d) => -d.$2);

      final lines = [
        for (final d in drops)
          '  ${d.$1.name.padRight(15)} '
              '${money(old[d.$1.sku]!.price)} -> ${money(d.$1.price)}  '
              '(-${money(d.$2)})',
      ];
      final biggest = drops.first;
      final savings = drops.fold(0.0, (s, d) => s + d.$2);

      return '${drops.length}|${lines.first}|${lines.last}'
          '|Biggest drop: ${biggest.$1.name} (-${money(biggest.$2)})'
          '|Total savings if bought now: ${money(savings)}';
    },
  );
}
