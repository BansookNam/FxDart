import 'package:fxdart/fxdart.dart';

void main() {
  // Two arguments: pass a record, and say how to compare it.
  var runs = 0;
  final label = fxMemoizeLast<(List<String>, int), String>(
    (k) {
      runs++;
      return k.$1.take(k.$2).join(', ');
    },
    equals: (a, b) => identical(a.$1, b.$1) && a.$2 == b.$2,
  );

  final names = ['ann', 'bo', 'cy'];
  print(label((names, 2))); // ann, bo
  print(label((names, 2))); // ann, bo  (cached)
  print(label((names, 3))); // ann, bo, cy
  print('ran $runs times'); // ran 2 times

  // Versus fxMemoize, which keeps every argument it has seen:
  final all = fxMemoize((int n) => n * n);
  for (var i = 0; i < 3; i++) {
    all(i);
  }
  print('fxMemoize holds 3 entries; fxMemoizeLast holds 1');
}
