import 'package:fxdart/fxdart.dart';

void main() {
  var calls = 0;
  final square = memoize<int, int>((n) {
    calls++;
    return n * n;
  });

  print(square(5)); // 25
  print(square(5)); // 25 (cached)
  print(square(6)); // 36
  print('square ran $calls times'); // square ran 2 times — not 3
}
