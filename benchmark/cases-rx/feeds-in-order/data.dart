// Deterministic two-feed log fixture, shared verbatim by both sides:
// the tail of yesterday's log (2/5 of n) then today's log (the rest),
// as (time, message) records like the example.
import '../../harness.dart';

final n = caseN(1000000);

final int nYesterday = n * 2 ~/ 5;
final int nToday = n - nYesterday;

final List<(String, String)> yesterdayTail = List.generate(
    nYesterday, (i) => (_clock(23 * 3600 + i % 3600), 'yday event $i'));
final List<(String, String)> todayLog =
    List.generate(nToday, (i) => (_clock(i % 86400), 'today event $i'));

String _clock(int seconds) {
  final h = (seconds ~/ 3600) % 24;
  final m = (seconds ~/ 60) % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}
