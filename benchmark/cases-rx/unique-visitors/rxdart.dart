import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final visits = makeVisits();
  await bench(
    slug: 'unique-visitors',
    impl: 'rxdart',
    n: n,
    run: () async {
      // distinctUnique dedups across the WHOLE stream (plain Stream.distinct
      // is adjacent-only); "same visitor" is spelled as equals + hashCode.
      final firstSeen = await Stream.fromIterable(visits)
          .distinctUnique(
              equals: (a, b) => a.user == b.user,
              hashCode: (v) => v.user.hashCode)
          .map((v) => '${v.user} — first visit ${v.at}')
          .toList();
      return '${firstSeen.length}|${firstSeen.first}|${firstSeen.last}';
    },
  );
}
