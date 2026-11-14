import 'package:fxdart/fxdart.dart';

void main() {
  var runs = 0;
  int total(List<int> xs) {
    runs++;
    return fx(xs).sum().toInt();
  }

  final state = [1, 2, 3];

  // TODO: wrap total in fxMemoizeLast so the three calls on the
  // same list run it once.
  final cached = total;

  print([cached(state), cached(state), cached(state)]); // [6, 6, 6]
  print('runs: $runs'); // should print: runs: 1
}
