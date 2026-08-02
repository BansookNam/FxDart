import 'package:rxdart/rxdart.dart';

// Tonight's event feed — everything after SHUTDOWN belongs to the next run.
const events = [
  'boot',
  'listen :8080',
  'GET /orders',
  'GET /health',
  'SIGTERM',
  'drain connections',
  'SHUTDOWN',
  'GET /too-late',
  'worker respawn',
];

Future<void> main() async {
  final kept = await Stream.fromIterable(events)
      // Inclusive stop, spelled as while-NOT-marker.
      .takeWhileInclusive((e) => e != 'SHUTDOWN')
      .map((e) => 'event: $e')
      .toList();

  kept.forEach(print);
}
