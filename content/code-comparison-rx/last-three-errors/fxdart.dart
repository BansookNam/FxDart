import 'package:fxdart/fxdart.dart';

// This morning's service log, oldest first.
const logLines = [
  'INFO  boot complete',
  'ERROR disk quota exceeded',
  'INFO  sync started',
  'ERROR timeout contacting registry',
  'WARN  retrying registry',
  'ERROR registry unreachable',
  'INFO  sync resumed',
  'ERROR checksum mismatch on chunk 7',
  'INFO  sync finished',
];

void main() {
  // takeRight keeps a 3-slot window while draining the iterable — the
  // last three are only knowable once the source is exhausted.
  final recent =
      fx(logLines).filter((l) => l.startsWith('ERROR')).takeRight(3).toList();

  recent.forEach(print);
}
