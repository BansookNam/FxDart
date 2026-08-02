import 'package:rxdart/rxdart.dart';

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

Future<void> main() async {
  // takeLast cannot emit anything until the source is done — the last
  // three are only knowable once the done event arrives.
  final recent = await Stream.fromIterable(logLines)
      .where((l) => l.startsWith('ERROR'))
      .takeLast(3)
      .toList();

  recent.forEach(print);
}
