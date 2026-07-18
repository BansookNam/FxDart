import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final cheapest = await fx([30, 12, 45, 9, 60])
      .toAsync()
      .map((price) => delay(const Duration(milliseconds: 100), price))
      .min();

  print(cheapest); // 9
}
