import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'feeds-in-order',
    impl: 'rxdart',
    n: n,
    run: () async {
      final lines = await Stream.fromIterable(yesterdayTail)
          // concatWith subscribes to today's stream only after yesterday's
          // completes — that sequencing is the ordering guarantee.
          .concatWith([Stream.fromIterable(todayLog)])
          .map((e) => '${e.$1}  ${e.$2}')
          .toList();
      return '${lines.length}|${lines.first}|${lines[nYesterday]}|${lines.last}';
    },
  );
}
