import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'food-spending',
    impl: 'native',
    n: n,
    run: () {
      final total = txns
          .where((t) => t.category == 'Food')
          .fold(0.0, (sum, t) => sum + t.amount);
      return total.toStringAsFixed(2);
    },
  );
}
