import 'package:fxdart/fxdart.dart';

/// Converts an amount in a foreign currency, slowly.
Future<double> toEuro(double amount) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return amount * 0.5;
}

void main() async {
  final charges = [10.0, 4.0, 6.0, 20.0];

  // The fetch runs three at a time; the fold stays in order.
  final running = await fx(charges)
      .toAsync()
      .map(toEuro)
      .concurrent(3)
      .mapAccum((double total, eur) => total + eur, 0.0)
      .toList();
  print(running); // [5.0, 7.0, 10.0, 20.0]

  // The seed may be a Future too — it is awaited before the first fold.
  final fromOpening = await fx([1, 2, 3])
      .toAsync()
      .mapAccum((int acc, a) => acc + a, Future.value(100))
      .toList();
  print(fromOpening); // [101, 103, 106]
}
