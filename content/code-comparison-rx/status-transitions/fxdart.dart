import 'package:fxdart/fxdart.dart';

// Health-check feed, one status per probe.
const feed = ['ok', 'ok', 'warn', 'warn', 'ok', 'ok', 'ok'];

void main() {
  final changes = fx(feed)
      .uniqAdjacent() // drops repeats of the predecessor: one per run
      .map((s) => 'status now: $s')
      .toList();

  // The global cousin: uniq dedups across the whole feed, so 'ok'
  // survives only once.
  final seen = fx(feed).uniq().toList();

  changes.forEach(print);
  print('statuses seen: ${seen.join(', ')}');
}
