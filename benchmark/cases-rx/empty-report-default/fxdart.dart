import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'empty-report-default',
    impl: 'fxdart',
    n: n,
    run: () {
      final report = fx(txns)
          .filter((t) => t.category == 'travel')
          .map((t) => '${t.date}  travel  ${t.amount}')
          .defaultIfEmpty('no travel spending recorded in August')
          .toList();
      return '${report.length}|${report.first}';
    },
  );
}
