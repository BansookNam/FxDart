import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [
    (name: 'ana', score: 71),
    (name: 'bo', score: 94),
    (name: 'cy', score: 88),
    (name: 'di', score: 94),
  ];

  // Top 3, biggest first — reads as written, no minus sign:
  final top = fx(scores).sortByDesc((p) => p.score).take(3).toList();
  print([for (final p in top) p.name]); // [bo, di, cy]

  // was: sortBy((p) => -p.score) — works, but only because score is a number.

  // Ties: equal keys stay adjacent; sortByDesc is sortBy with the
  // comparison swapped, so bo and di (both 94) lead the ranking.
  print(sortByDesc((int n) => n, [3, 1, 4, 1, 5])); // [5, 4, 3, 1, 1]
}
