import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'running-balance',
    impl: 'native',
    n: n,
    run: () {
      // No scan in core Dart: fold only returns the final value, so the
      // running state has to live in a mutable variable.
      var balance = 250.0;
      final lines = [
        '${'Opening balance'.padRight(15)} \$${balance.toStringAsFixed(2)}',
      ];
      for (final t in txns) {
        balance += t.amount;
        lines.add('${t.label.padRight(15)} \$${balance.toStringAsFixed(2)}');
      }
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
