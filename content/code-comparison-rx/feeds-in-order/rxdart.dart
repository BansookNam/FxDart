import 'package:rxdart/rxdart.dart';

// The tail of yesterday's log, then today's log — order must be kept.
const yesterdayTail = [
  ('23:41', 'cache flushed'),
  ('23:52', 'nightly backup started'),
  ('23:58', 'nightly backup finished'),
];
const todayLog = [
  ('00:04', 'cache warmed'),
  ('00:12', 'first request served'),
  ('06:30', 'daily report generated'),
  ('07:02', 'queue drained'),
];

Future<void> main() async {
  final lines = await Stream.fromIterable(yesterdayTail)
      // concatWith subscribes to today's stream only after yesterday's
      // completes — that sequencing is the ordering guarantee.
      .concatWith([Stream.fromIterable(todayLog)])
      .map((e) => '${e.$1}  ${e.$2}')
      .toList();

  for (var i = 0; i < lines.length; i++) {
    print('${i + 1}. ${lines[i]}');
  }
}
