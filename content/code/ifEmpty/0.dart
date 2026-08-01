import 'package:fxdart/fxdart.dart';

void main() {
  final expenses = [
    (category: 'food', amount: 32.5),
    (category: 'food', amount: 18.0),
    (category: 'transport', amount: 12.0),
  ];

  // Aggressive filtering can leave nothing — defaultIfEmpty puts the
  // placeholder INSIDE the pipeline instead of an if/else after it:
  final travel = fx(expenses)
      .filter((e) => e.category == 'travel')
      .map((e) => e.amount)
      .defaultIfEmpty(0.0)
      .toList();
  print(travel); // [0.0]

  // Non-empty chains pass through untouched:
  final food = fx(expenses)
      .filter((e) => e.category == 'food')
      .map((e) => e.amount)
      .defaultIfEmpty(0.0)
      .toList();
  print(food); // [32.5, 18.0]
}
