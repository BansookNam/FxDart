import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'date-window-spend',
    impl: 'native',
    n: n,
    run: () {
      final total = txns
          .skipWhile((t) => t.date.compareTo(start) < 0)
          .takeWhile((t) => t.date.compareTo(end) <= 0)
          .fold(0.0, (sum, t) => sum + t.amount);
      return total.toStringAsFixed(2);
    },
  );
}
