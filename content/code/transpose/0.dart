import 'package:fxdart/fxdart.dart';

void main() {
  // transpose takes the rows as ONE iterable of iterables:
  final rows = [
    [1, 2, 3],
    [4, 5, 6],
  ];
  print(transpose(rows)); // ([1, 4], [2, 5], [3, 6])

  // Ragged rows: once a row runs out it just stops contributing.
  final ragged = [
    [1, 2, 3],
    [4, 5],
  ];
  print(transpose(ragged)); // ([1, 4], [2, 5], [3])
}
