import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'compound-interest',
    impl: 'native',
    n: n,
    run: () {
      final table = <String>['year 0: \$${principal.toStringAsFixed(2)}'];
      var balance = principal;
      for (var year = 1; year <= n; year++) {
        balance = balance * (1 + rate);
        table.add('year $year: \$${balance.toStringAsFixed(2)}');
      }
      return '${table.length}|${table.first}|${table.last}';
    },
  );
}
