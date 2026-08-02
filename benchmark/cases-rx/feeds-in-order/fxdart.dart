import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'feeds-in-order',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(yesterdayTail)
          // concat pulls from today's feed only once yesterday's runs out.
          .concat(todayLog)
          .map((e) => '${e.$1}  ${e.$2}')
          .toList();
      return '${lines.length}|${lines.first}|${lines[nYesterday]}|${lines.last}';
    },
  );
}
