import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

/// The example's second spelling, `takeUniqBy`. Not what the bars measure —
/// they measure the composable chain the page presents as the default — but
/// run once here so the two spellings cannot drift apart at benchmark scale.
String _strictChecksum(List<Log> logs) {
  final recent = takeUniqBy(
    3,
    (Log l) => l.level == 'ERROR' ? l.message : null,
    logs,
  );
  return recent.map((l) => '${l.time} ${l.message}').join('|');
}

String _chainChecksum(List<Log> logs) {
  final recent = fx(
    logs,
  ).filter((l) => l.level == 'ERROR').uniqBy((l) => l.message).take(3);
  return recent.map((l) => '${l.time} ${l.message}').join('|');
}

Future<void> main() async {
  final logs = makeLogs();
  // Outside the timed closure: the bars measure the composable chain alone.
  if (_chainChecksum(logs) != _strictChecksum(logs)) {
    throw StateError('takeUniqBy disagrees with the composable chain');
  }
  await bench(
    slug: 'recent-errors',
    impl: 'fxdart',
    n: n,
    run: () => _chainChecksum(logs),
  );
}
