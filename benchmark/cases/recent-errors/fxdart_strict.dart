// The example's second spelling: `takeUniqBy`, the strict form.
//
// This case is the one place a third bar is measured. The page shows both
// spellings because the gap between them is the point it makes — a lazy stage
// keeps its callback in an iterator field, which AOT cannot see through, so
// the composable chain pays two un-inlinable calls per element that this one
// does not. The composable chain stays the headline: it is what the page
// teaches by default.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'recent-errors',
    impl: 'fxdart_strict',
    n: n,
    run: () {
      final recent = takeUniqBy(
        3,
        (Log l) => l.level == 'ERROR' ? l.message : null,
        logs,
      );
      return recent.map((l) => '${l.time} ${l.message}').join('|');
    },
  );
}
