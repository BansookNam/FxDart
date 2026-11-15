import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [
    (name: 'ada', score: 5),
    (name: 'bo', score: 9),
    (name: 'cy', score: 5),
    (name: 'di', score: 1),
    (name: 'ed', score: 9),
  ];
  List<String> names(List<({String name, int score})> rs) =>
      [for (final r in rs) r.name];

  // The k largest, largest first:
  print(names(fxTopBy(2, (r) => r.score, scores))); // [bo, ed]

  // Ties: the element seen first wins, and keeps its place.
  print(names(fxTopBy(1, (r) => r.score, scores))); // [bo]
  print(names(fxTopBy(3, (r) => r.score, scores))); // [bo, ed, ada]

  // bottomBy is the mirror: the k smallest, smallest first.
  print(names(fxBottomBy(2, (r) => r.score, scores))); // [di, ada]

  // k <= 0 is empty; a k past the end is everything, ordered.
  print(fxTopBy(0, (r) => r.score, scores)); // []
  print(names(fxTopBy(9, (r) => r.score, scores)));
  // [bo, ed, ada, cy, di]
}
