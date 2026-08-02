import 'package:fxdart/fxdart.dart';

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

void main() {
  final lines = fx(yesterdayTail)
      // concat pulls from today's feed only once yesterday's runs out.
      .concat(todayLog)
      .map((e) => '${e.$1}  ${e.$2}')
      .toList();

  for (var i = 0; i < lines.length; i++) {
    print('${i + 1}. ${lines[i]}');
  }
}
