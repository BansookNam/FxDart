import 'package:fxdart/fxdart.dart';

void main() {
  final finishers = ['Kim', 'Lee', 'Park'];
  const suffix = ['st', 'nd', 'rd'];

  // TODO: number the finishers 1st, 2nd, 3rd using the index.
  final board =
      fx(finishers).mapWithIndex((name, i) => '${i + 1}${suffix[i]} $name');

  print(board.toList()); // [1st Kim, 2nd Lee, 3rd Park]
}
