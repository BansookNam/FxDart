import 'package:fxdart/fxdart.dart';

void main() {
  final log = [
    'INFO boot',
    'INFO ready',
    'WARN disk 81%',
    'WARN disk 82%',
    'ERROR write failed',
    'WARN disk 83%',
    'INFO recovered',
  ];

  // TODO: report one line per LEVEL run — when the level changes, keep
  // that line; drop the repeats of the same level.
  // Hint: the level is the first word — line.split(' ').first.
  final levelChanges = fx(log)
      .uniqAdjacent() // ← almost: this compares whole lines. Compare by level.
      .toList();

  levelChanges.forEach(print);
  // Expected once solved:
  // INFO boot
  // WARN disk 81%
  // ERROR write failed
  // WARN disk 83%
  // INFO recovered
}
