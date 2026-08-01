import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['fig', 'banana', 'apple'];

  // Each value, paired with what you derived from it — lazily:
  final pairs = fx(words).attach((w) => w.length).toList();
  print(pairs); // [(fig, 3), (banana, 6), (apple, 5)]

  // The input survives, so downstream steps can use BOTH sides:
  final labeled = fx(words)
      .attach((w) => w.length)
      .filter((p) => p.$2 > 3)
      .map((p) => '${p.$1} (${p.$2} letters)')
      .toList();
  print(labeled); // [banana (6 letters), apple (5 letters)]

  // was: .map((w) => (w, w.length)) — hand-built records, every time.
}
