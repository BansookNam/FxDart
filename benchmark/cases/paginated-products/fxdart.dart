import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final products = makeProducts();
  await bench(
    slug: 'paginated-products',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(products)
          .filter((p) => p.inStock)
          .sortBy((p) => p.price)
          .drop((page - 1) * pageSize)
          .take(pageSize)
          .map((p) => '${p.name} — \$${p.price.toStringAsFixed(2)}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
