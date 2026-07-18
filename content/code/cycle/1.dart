import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // cycleAsync/.cycle() on an FxAsync chain works the same way — still
  // pair it with .take(n), just on the async side.
  final result = await fx(['x', 'y'])
      .toAsync()
      .cycle()
      .map((a) => delay(const Duration(milliseconds: 50), a.toUpperCase()))
      .take(5)
      .toArray();

  print(result); // [X, Y, X, Y, X]
}
