import 'package:fxdart/fxdart.dart';

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

void main() {
  fx(events)
      // Inclusive stop, spelled as until-marker.
      .takeUntilInclusive((e) => e == 'SHUTDOWN')
      .map((e) => 'event: $e')
      .toList()
      .forEach(print);
}
