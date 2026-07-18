import 'package:fxdart/fxdart.dart';

void main() {
  var calls = 0;

  // TODO: wrap this function with memoize
  final cached = memoize<int, int>((n) {
    calls++;
    return n * n * n;
  });

  print([cached(3), cached(3), cached(4)]); // [27, 27, 64]
  print('calls: $calls'); // calls: 2
}
