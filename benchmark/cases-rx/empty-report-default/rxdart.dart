import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'empty-report-default',
    impl: 'rxdart',
    n: n,
    run: () async {
      final report = await Stream.fromIterable(txns)
          .where((t) => t.category == 'travel')
          .map((t) => '${t.date}  travel  ${t.amount}')
          .defaultIfEmpty('no travel spending recorded in August')
          .toList();
      return '${report.length}|${report.first}';
    },
  );
}
