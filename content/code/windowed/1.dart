import 'package:fxdart/fxdart.dart';

void main() {
  final days = [1, 2, 3, 4, 5, 6, 7];

  // step < size: overlapping windows (the default, step: 1).
  print(fx(days).windowed(3, step: 2).toList());
  // [[1, 2, 3], [3, 4, 5], [5, 6, 7]]

  // step == size + partial: exactly chunk — they share one implementation.
  print(fx(days).windowed(3, step: 3, partial: true).toList());
  // [[1, 2, 3], [4, 5, 6], [7]]
  print(fx(days).chunk(3).toList()); // same

  // partial keeps the shrinking tail of a sliding window too:
  print(fx([1, 2, 3, 4]).windowed(3, partial: true).toList());
  // [[1, 2, 3], [2, 3, 4], [3, 4], [4]]

  // Lazy: an endless source is fine — only what you take is computed.
  print(fx(range(1, 1000000)).windowed(4, step: 4).take(2).toList());
  // [[1, 2, 3, 4], [5, 6, 7, 8]]
}
