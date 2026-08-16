import 'package:fxdart/fxdart.dart';

// Rule 1: end an eager chain in toList(), and let the terminal do the work.
void main() {
  final prices = [12.5, 8.0, 30.0, 4.25, 19.9];

  // A terminal operator sees the whole chain and can take a fast path —
  // map().toList() over a List hands the copy to the SDK's own bulk fill.
  final labels = fx(prices).map((p) => '\$${p.toStringAsFixed(2)}').toList();
  print(labels);

  // Pulling the same chain by hand element-by-element cannot use any of that.
  final byHand = <String>[];
  for (final p in fx(prices).map((p) => '\$${p.toStringAsFixed(2)}')) {
    byHand.add(p);
  }
  print(byHand); // same answer, more work

  // Rule 2: filter before you map, so the expensive callback runs less often.
  var calls = 0;
  fx(prices)
      .filter((p) => p > 10) // cheap test first
      .map((p) {
        calls++; // expensive work second
        return p * 1.2;
      })
      .toList();
  print('callback ran $calls times, not ${prices.length}');
}
