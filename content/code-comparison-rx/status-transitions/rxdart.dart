import 'package:rxdart/rxdart.dart';

// Health-check feed, one status per probe.
const feed = ['ok', 'ok', 'warn', 'warn', 'ok', 'ok', 'ok'];

Future<void> main() async {
  final changes = await Stream.fromIterable(feed)
      .distinct() // plain Stream.distinct is adjacent-only: one per run
      .map((s) => 'status now: $s')
      .toList();

  // The global cousin: rxdart's distinctUnique dedups across the whole
  // stream, so 'ok' survives only once.
  final seen = await Stream.fromIterable(feed).distinctUnique().toList();

  changes.forEach(print);
  print('statuses seen: ${seen.join(', ')}');
}
