import 'package:fxdart/fxdart.dart';

void main() {
  // Heartbeat timestamps, in seconds. Anything > 5s apart is a gap.
  final beats = [0, 3, 6, 14, 17, 30, 33];

  // TODO: pair each timestamp with the next one and report the gaps —
  // pairs whose distance is more than 5 seconds.
  final gaps = fx(beats)
      .pairwise() // ← filter the pairs, then format '${p.$1}s → ${p.$2}s'
      .toList();

  print(gaps);
  // Expected once solved: [6s → 14s, 17s → 30s]
}
