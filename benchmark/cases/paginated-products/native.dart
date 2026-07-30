import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final products = makeProducts();
  await bench(
    slug: 'paginated-products',
    impl: 'native',
    n: n,
    run: () {
      final inStock = products.where((p) => p.inStock).toList()
        ..sort((a, b) => a.price.compareTo(b.price));
      final lines = inStock
          .skip((page - 1) * pageSize)
          .take(pageSize)
          .map((p) => '${p.name} — \$${p.price.toStringAsFixed(2)}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
