import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final visits = makeVisits();
  await bench(
    slug: 'unique-visitors',
    impl: 'fxdart',
    n: n,
    run: () {
      // uniqBy keeps the first element per key — "same visitor" is one
      // key function, and the record's user field is the key.
      final firstSeen = fx(visits)
          .uniqBy((v) => v.user)
          .map((v) => '${v.user} — first visit ${v.at}')
          .toList();
      return '${firstSeen.length}|${firstSeen.first}|${firstSeen.last}';
    },
  );
}
