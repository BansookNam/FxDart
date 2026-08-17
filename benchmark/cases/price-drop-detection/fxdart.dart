import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final june = makeJune();
  final july = makeJuly();
  await bench(
    slug: 'price-drop-detection',
    impl: 'fxdart',
    n: n,
    run: () {
      final old = fx(june).indexBy((i) => i.sku);
      final drops = fx(july)
          .filter((i) => old.containsKey(i.sku) && i.price < old[i.sku]!.price)
          .map((i) => (i, old[i.sku]!.price - i.price))
          .sortBy((d) => -d.$2)
          .toList();

      // materialized (the example spreads the lazy lines into print)
      final lines = fx(drops)
          .map(
            (d) =>
                '  ${d.$1.name.padRight(15)} '
                '${money(old[d.$1.sku]!.price)} -> ${money(d.$1.price)}  '
                '(-${money(d.$2)})',
          )
          .toList();
      final biggest = fx(drops).head()!;
      final savings = fx(drops).sumBy((d) => d.$2);

      return '${drops.length}|${lines.first}|${lines.last}'
          '|Biggest drop: ${biggest.$1.name} (-${money(biggest.$2)})'
          '|Total savings if bought now: ${money(savings)}';
    },
  );
}
