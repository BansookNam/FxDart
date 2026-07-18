import 'package:fxdart/fxdart.dart';

void main() {
  var calls = 0;
  Iterable<int> source() sync* {
    for (var i = 1; i <= 5; i++) {
      calls++;
      yield i;
    }
  }

  final shared = source();

  // Both branches fork the SAME `shared` object, so they share one buffered
  // iteration of the underlying generator:
  final evens = fork(shared).where((a) => a.isEven).toList();
  final doubled = fork(shared).map((a) => a * 2).toList();

  print(evens); // [2, 4]
  print(doubled); // [2, 4, 6, 8, 10]
  print('source ran $calls times'); // 5 — not 10
}
