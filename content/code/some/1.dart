import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final anyOnline = await fx(['off', 'off', 'on'])
      .toAsync()
      .any((s) => fxDelay(Duration(milliseconds: 30), s == 'on'));
  print(anyOnline); // true

  final anyNegative = await fxAnyAsync(
      (a) => fxDelay(Duration(milliseconds: 30), a < 0), fx([1, 2, 3]).toAsync());
  print(anyNegative); // false
}
