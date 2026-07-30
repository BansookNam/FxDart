import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'first-visit-merchants',
    impl: 'native',
    n: n,
    run: () {
      // Iterable.toSet() happens to preserve insertion order today, but its
      // contract doesn't promise it — a seen-set loop states the intent.
      final seen = <String>{};
      final merchants = <String>[];
      for (final t in txns) {
        if (seen.add(t.merchant)) merchants.add(t.merchant);
      }
      return '${merchants.length}|${merchants.first}|${merchants.last}';
    },
  );
}
